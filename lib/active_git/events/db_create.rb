module ActiveGit
  class DbCreate < DbEvent

    def synchronize(synchronizer)
      create synchronizer
    end

  end
end