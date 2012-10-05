module ActiveGit
  class DbCreate < DbEvent

    def synchronize(synchronizer)
      synchronizer.bulk_insert data
    end

  end
end