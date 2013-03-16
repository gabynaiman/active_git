module ActiveGit
  module ActiveRecord

    module ClassMethods

      def git_versioned
        ActiveGit.models << self

        after_save do |record|
          Synchronizer.synchronize FileSave.new(record)
        end

        after_destroy do |record|
          Synchronizer.synchronize FileDelete.new(record)
        end

        def from_json(json)
          record = self.new
          hash = json.is_a?(Hash) ? json : JSON.parse(json)
          hash.each do |attr, value|
            if record.respond_to? "#{attr}="
              if self.columns_hash[attr].type == :datetime
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
  end
end