require 'coverage_helper'
require 'active_git'
require 'logger'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

ActiveRecord::Base.logger = Logger.new($stdout)
ActiveRecord::Base.logger.level = Logger::Severity::ERROR
ActiveRecord::Migrator.migrations_path = "#{File.dirname(__FILE__)}/migrations"

ActiveGit.configuration.logger.level = Logger::Severity::ERROR

module InflectorHelper
  def git_dirname(model, working_path=nil)
    ActiveGit::Inflector.dirname(model, working_path || ActiveGit.configuration.working_path)
  end

  def git_filename(instance, working_path=nil)
    ActiveGit::Inflector.filename(instance, working_path || ActiveGit.configuration.working_path)
  end
end

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

  include InflectorHelper

end