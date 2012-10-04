module ActiveGit
  class SynchronizationError < StandardError

    def initialize(models)
      @models = models
    end

    def message
      messages = []
      @models.each do |model|
        model.errors.full_messages.each do |msg|
          attributes = {}
          model.attributes.each do |name, value|
            attributes[model.class.human_attribute_name(name)] = value
          end

          attributes = model.attributes.inject({}) do |memo, item|
            memo[model.class.human_attribute_name(item[0])] = item[1]
            memo
          end

          messages << "#{model.class.model_name.human} - #{msg}\n#{attributes}"
        end
      end
      messages.join("\n")
    end

    def to_s
      "#{self.class.name} (#{message}):\n#{backtrace.join("\n")}"
    end

  end
end