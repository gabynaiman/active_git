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

  end
end