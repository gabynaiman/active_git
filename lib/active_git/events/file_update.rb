module ActiveGit
  class FileUpdate < FileEvent

    def synchronize(synchronizer)
      synchronizer.file_save file_name, json
    end

  end
end