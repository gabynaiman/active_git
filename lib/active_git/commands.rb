module ActiveGit
  module Commands

    GitWrapper::Repository.instance_methods(false).each do |method|
      define_method method do |*args, &block|
        repository.send method, *args, &block
      end
    end

    def dump_db(*models)
      events = (Dir["#{ActiveGit.configuration.working_path}/*"] - ActiveGit.models.map { |m| Inflector.dirname(m) }).map do |folder|
        FolderRemove.new(folder)
      end
      
      (models.any? ? models : ActiveGit.models).each do |model|
        events << FolderRemove.new(Inflector.dirname(model))
        events = events + model.all.map { |r| FileSave.new r }
      end
      
      Synchronizer.synchronize events
    end

    def load_files(*models)
      events = []

      (models.any? ? models : ActiveGit.models).each do |model|
        events << DbDeleteAll.new(model)
        Dir.glob("#{Inflector.dirname(model)}/*.json").each do |file_name|
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
      ActiveGit.configuration.logger.info "[ActiveGit] Fetch #{remote} #{branch}"
      fetch remote
      merge "#{remote}/#{branch}"
    end

    def merge(commit)
      ActiveGit.configuration.logger.info "[ActiveGit] Merge Init"

      last_log = (log || []).first
      diffs = diff_reverse commit unless last_log

      ActiveGit.configuration.logger.info "[ActiveGit] Merge repo GIT"
      unless repository.merge(commit)
        resolve_conflicts
        commit_all 'Resolve conflicts'
      end

      ActiveGit.configuration.logger.info "[ActiveGit] Diff #{last_log.commit_hash}..HEAD"
      diffs ||= repository.diff("#{last_log.commit_hash}..HEAD")
      begin
        synchronize_diffs diffs
      rescue => e
        ActiveGit.configuration.logger.error "[ActiveGit] #{e}"
        repository.reset mode: :hard, commit: last_log.commit_hash || 'HEAD'
        return false
      end
      ActiveGit.configuration.logger.info "[ActiveGit] Merge End"

      true
    end

    def conflicts
      status.select { |e| e.status == :merge_conflict }.map { |e| e.file_name }
    end

    def resolve_conflicts
      ActiveGit.configuration.logger.info "[ActiveGit] Resolve conflicts"
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

        FileSave.new(ModelParser.from_json(model, merge))
      end

      ActiveGit.configuration.logger.info "[ActiveGit] Resolve conflicts synchornize events"
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
      ActiveGit.configuration.logger.info "[ActiveGit] Reset Init"
      diffs = diff_reverse commit
      ActiveGit.configuration.logger.info "[ActiveGit] Reset repo GIT"
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
      ActiveGit.configuration.logger.info "[ActiveGit] Synchronize diffs"
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
      ActiveGit.configuration.logger.info "[ActiveGit] Init synchronize diff events"
      Synchronizer.synchronize events
    end

  end
end