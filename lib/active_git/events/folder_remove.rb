module ActiveGit
  class FolderRemove

    def initialize(path)
      @path = path
    end

    def synchronize(synchronizer)
      synchronizer.define_job do
        ActiveGit.configuration.logger.debug "[ActiveGit] Removing folder #{@path}"
        FileUtils.rm_rf @path
      end
    end

  end
end