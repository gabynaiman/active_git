module ActiveGit
  class FileDelete < FileEvent

    def synchronize(synchronizer)
      synchronizer.define_job do
        ::ActiveRecord::Base.logger.debug "[ActiveGit] Deleting file #{file_name}"
        File.delete(file_name) if File.exist?(file_name)
      end
    end

  end
end