module ActiveGit
  class FileEvent

    def initialize(data, path=nil)
      @data = data
      @path = path || ActiveGit.configuration.working_path
    end

    def synchronize(synchronizer)
      raise 'Must implement in subclass'
    end

    protected

    def model
      @data.class.to_s.classify.constantize
    end

    def model_path
      "#{@path}/#{model.table_name}"
    end

    def file_name
      "#{model_path}/#{@data.id}.json"
    end

    def json
      JSON.pretty_generate(@data.attributes)
    end

  end
end