module ActiveGit
  class FolderRemove

    def initialize(path)
      @path = path
    end

    def synchronize(synchronizer)
      synchronizer.define_job do
        ::ActiveRecord::Base.logger.debug "[ActiveGit] Removing working folder #{@path}"
        FileUtils.rm_rf @path
      end
    end

  end
end