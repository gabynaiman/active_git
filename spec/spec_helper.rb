require 'active_git'
require 'logger'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

TEMP_PATH = ENV['TMP'].gsub("\\", '/')

ActiveRecord::Base.logger = Logger.new($stdout)
ActiveRecord::Migrator.migrations_path = "#{File.dirname(__FILE__)}/migrations"

RSpec.configure do |config|
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end

  config.before :all do
    ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ":memory:"
    ActiveRecord::Base.connection
    ActiveRecord::Migrator.migrate ActiveRecord::Migrator.migrations_path
  end
end