module ActiveGit
  class DbUpdate < DbEvent

    def synchronize(synchronizer)
      delete synchronizer
      create synchronizer
    end

  end
end