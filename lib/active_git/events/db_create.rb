module ActiveGit
  class DbCreate < DbEvent

    def synchronize(synchronizer)
      synchronizer.db_create data
    end

  end
end