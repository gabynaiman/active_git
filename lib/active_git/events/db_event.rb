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
      record = model.new
      json = JSON.parse(File.open(@file_name, 'r') { |f| f.readlines.join("\n") })
      json.each do |attr, value|
        if record.respond_to?(attr)
          if model.columns_hash[attr].type == :datetime
            record.send("#{attr}=", Time.parse(value).utc)
          else
            record.send("#{attr}=", value)
          end
        end
      end
      record
    end

  end
end