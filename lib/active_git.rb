require 'active_record'
require 'git_wrapper'
require 'activerecord-import'
require 'json'

require 'active_git/version'
require 'active_git/synchronizer'
require 'active_git/events/db_event'
require 'active_git/events/db_create'
require 'active_git/events/db_update'
require 'active_git/events/db_delete'
require 'active_git/events/file_event'
require 'active_git/events/file_create'
require 'active_git/events/file_update'
require 'active_git/events/file_delete'
require 'active_git/active_record_extension'
require 'active_git/configuration'

module ActiveGit

  def self.configuration
    @@configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

end

ActiveRecord::Base.send :extend, ActiveGit::ActiveRecord::ClassMethods

