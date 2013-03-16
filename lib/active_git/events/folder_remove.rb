module ActiveGit
  class FolderRemove

    def initialize(working_path)
      @working_path = working_path
    end

    def synchronize(synchronizer)
      synchronizer.define_job do
        ActiveGit.configuration.logger.debug "[ActiveGit] Removing folder #{@working_path}"
        FileUtils.rm_rf @working_path
      end
    end

  end
end