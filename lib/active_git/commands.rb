module ActiveGit
  module Commands

    GitWrapper::Repository.instance_methods(false).each do |method|
      define_method method do |*args, &block|
        repository.send method, *args, &block
      end
    end

    def dump_db
      events = [FolderRemove.new(ActiveGit.configuration.working_path)]

      ActiveGit.models.each do |model|
        model.all.each do |record|
          events << FileSave.new(record)
        end
      end

      Synchronizer.synchronize events
    end

    def load_files
      events = []

      ActiveGit.models.each do |model|
        events << DbDeleteAll.new(model)
        Dir.glob("#{model.git_folder}/*.json").each do |file_name|
          events << DbCreate.new(file_name)
        end
      end

      Synchronizer.synchronize events
    end

    def commit_all(message, options={})
      add_all
      commit(message, options)
    end

    def pull(remote='origin', branch='master')
      fetch remote
      merge "#{remote}/#{branch}"
    end

    def merge(commit)
      last_log = log.first
      diffs = diff_reverse commit unless last_log

      unless repository.merge(commit)
        resolve_conflicts
        diffs = diff 'HEAD'
        commit_all 'Resolve conflicts'
      end

      diffs ||= repository.diff(last_log.commit_hash)
      begin
        events = diffs.map do |d|
          file_name = "#{location}/#{d.file_name}"

          if d.status == :new_file
            DbCreate.new file_name
          elsif [:modified, :renamed, :copied].include? d.status
            DbUpdate.new file_name
          elsif d.status == :deleted
            DbDelete.new file_name
          else
            raise "Unexpected file status [#{d.status}]"
          end
        end

        Synchronizer.synchronize events
      rescue => e
        reset :mode => :hard, :commit => last_log.commit_hash
        raise e
      end

      true
    end

    def conflicts
      status.select { |e| e.status == :merge_conflict }.map { |e| e.file_name }
    end

    def resolve_conflicts
      json_parse = Proc.new do |text|
        text.present? ? JSON.parse(text) : {}
      end

      conflicts.each do |file_name|
        base = json_parse.call(show_base(file_name))
        mine = json_parse.call(show_mine(file_name))
        theirs = json_parse.call(show_theirs(file_name))

        r_diff, a_diff = base.easy_diff(mine)
        merge = theirs.easy_unmerge(r_diff).easy_merge(a_diff)

        File.open("#{location}/#{file_name}", 'w') do |f|
          f.puts JSON.pretty_generate(merge)
        end
      end
    end

  end
end