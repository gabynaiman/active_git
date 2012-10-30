module ActiveGit
  class Configuration

    def working_path
      @working_path.is_a?(Proc) ? @working_path.call : @working_path
    end

    def working_path=(path)
      @working_path = path
    end

    def bare_path
      @bare_path.is_a?(Proc) ? @bare_path.call : @bare_path
    end

    def bare_path=(path)
      @bare_path = path
    end

    def logger
      GitWrapper.logger
    end

    def logger=(logger)
      GitWrapper.logger = logger
    end

  end
end