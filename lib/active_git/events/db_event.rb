module ActiveGit
  class DbEvent

    def initialize(file_name)
      @file_name = file_name
    end

    def synchronize(synchronizer)
      raise 'Must implement in subclass'
    end

    protected

    def model
      @model ||= File.dirname(@file_name).split(/\/|\\/).pop.classify.constantize
    end

    def model_id
      File.basename(@file_name, '.json')
    end

    def data
      json = File.open(@file_name, 'r') { |f| f.readlines.join("\n") }
      model.from_json(json)
    end

  end
end