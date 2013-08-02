module ActiveGit
  class DbDelete < DbEvent

    def synchronize(synchronizer)
      delete synchronizer
    end

  end
end