module ActiveGit
  class FileSave < FileEvent

    def synchronize(synchronizer)
      synchronizer.define_job do
        ActiveGit.configuration.logger.debug "[ActiveGit] Writing file #{file_name}"
        FileUtils.mkpath(File.dirname(file_name)) unless Dir.exist?(File.dirname(file_name))
        File.open(file_name, 'w') { |f| f.puts data.git_dump }
      end

    end

  end
end