module ActiveGit
  class FileCreate < FileEvent

    def synchronize(synchronizer)
      synchronizer.file_save file_name, json
    end

  end
end