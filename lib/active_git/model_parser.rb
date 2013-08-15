module ActiveGit
  class ModelParser

    def self.instances(model, json)
      list = [from_json(model, json)]
      attributes = json.is_a?(Hash) ? json : JSON.parse(json)
      attributes.each do |attr, value|
        if model.reflections.has_key?(attr.to_sym)
          model = attr.to_s.classify.constantize
          if value.is_a? Array
            value.each {|json| list = list + instances(model, json)}
          else
            list = list + instances(model, json)
          end
        end
      end
      list
    end

    def self.from_json(model, json)
      record = model.new
      attributes = json.is_a?(Hash) ? json : JSON.parse(json)
      attributes.each do |attr, value|
        if model.column_names.include?(attr.to_s)
          if model.columns_hash[attr.to_s].type == :datetime && value.is_a?(String)
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