module ActiveGit
  module Commands

    GitWrapper::Repository.instance_methods(false).each do |method|
      define_method method do |*args, &block|
        repository.send method, *args, &block
      end
    end

    def dump_db(*models)
      events = (Dir["#{ActiveGit.configuration.working_path}/*"] - ActiveGit.models).map do |folder|
        FolderRemove.new(folder)
      end

      (models.any? ? models : ActiveGit.models).each do |model|
        events << FolderRemove.new(model.git_folder)
        events = events + model.all.map { |r| FileSave.new r }
      end

      Synchronizer.synchronize events
    end

    def load_files(*models)
      events = []

      (models.any? ? models : ActiveGit.models).each do |model|
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
        synchronize_diffs diffs
      rescue => e
        ActiveGit.configuration.logger.error "[ActiveGit] #{e}"
        reset last_log.commit_hash
        return false
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

      events = conflicts.map do |file_name|
        base = json_parse.call(show_base(file_name))
        mine = json_parse.call(show_mine(file_name))
        theirs = json_parse.call(show_theirs(file_name))

        r_diff, a_diff = base.easy_diff(mine)
        merge = theirs.easy_unmerge(r_diff).easy_merge(a_diff)

        model = File.dirname(file_name).split(/\/|\\/).pop.classify.constantize

        FileSave.new(model.from_json(merge))
      end

      Synchronizer.synchronize events
    end

    def checkout(commit, new_branch=nil)
      current = current_branch
      diffs = repository.diff_reverse commit
      if repository.checkout(commit.split('/').last, new_branch)
        begin
          synchronize_diffs diffs
        rescue SynchronizationError => e
          ActiveGit.configuration.logger.error "[ActiveGit] #{e}"
          repository.checkout current
          return false
        end
        true
      else
        false
      end
    end

    def reset(commit='HEAD')
      diffs = diff_reverse commit
      if repository.reset mode: :hard, commit: commit
        begin
          synchronize_diffs diffs
        rescue SynchronizationError => e
          ActiveGit.configuration.logger.error "[ActiveGit] #{e}"
          #TODO: Rollback reset
          return false
        end
        true
      else
        false
      end
    end

    private

    def synchronize_diffs(diffs)
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
    end

  end
end