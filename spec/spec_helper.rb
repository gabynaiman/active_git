require 'coverage_helper'
require 'active_git'
require 'logger'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

ActiveRecord::Migrator.migrations_path = "#{File.dirname(__FILE__)}/migrations"
ActiveRecord::Migration.verbose = false

logger = Logger.new($stdout)
logger.level = Logger::Severity::FATAL

ActiveRecord::Base.logger = logger
ActiveGit.configuration.logger = logger

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
    if ENV['DB'] == 'postgresql'
      ActiveRecord::Base.establish_connection adapter: 'postgresql', database: 'test', username: 'postgres'
    else
      ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
    end
    ActiveRecord::Base.connection
    ActiveRecord::Migrator.migrate ActiveRecord::Migrator.migrations_path
  end

  include InflectorHelper

end