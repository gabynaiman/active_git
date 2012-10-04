module ActiveGit
  class DbUpdate < DbEvent

    def synchronize(synchronizer)
      synchronizer.db_update data
    end

  end
end