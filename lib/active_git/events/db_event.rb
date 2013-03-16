module ActiveGit
  class DbEvent

    def initialize(file_name, working_path=nil)
      @file_name = file_name
      @working_path = working_path || ActiveGit.configuration.working_path
    end

    def synchronize(synchronizer)
      raise 'Must implement in subclass'
    end

    protected

    def model
      @model ||= Inflector.model(@file_name, @working_path)
    end

    def model_id
      Inflector.model_id @file_name
    end

    def data
      json = File.open(@file_name, 'r') { |f| f.readlines.join("\n") }
      model.from_json(json)
    end

  end
end