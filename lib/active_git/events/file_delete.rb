module ActiveGit
  class FileDelete < FileEvent

    def synchronize(synchronizer)
      synchronizer.file_delete file_name
    end

  end
end