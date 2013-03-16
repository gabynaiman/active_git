module ActiveGit
  class FileEvent

    def initialize(data, working_path=nil)
      @data = data
      @working_path = working_path || ActiveGit.configuration.working_path
    end

    def synchronize(synchronizer)
      raise 'Must implement in subclass'
    end

    protected

    def model
      @data.class
    end

    def model_path
      Inflector.dirname(model, @working_path)
    end

    def file_name
      Inflector.filename(@data, @working_path)
    end

    def json
      JSON.pretty_generate(@data.attributes)
    end

  end
end