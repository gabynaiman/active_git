require 'active_record'
require 'git_wrapper'
require 'activerecord-import'
require 'json'
require 'easy_diff'

require 'active_git/version'
require 'active_git/synchronizer'
require 'active_git/synchronization_error'
require 'active_git/events/db_event'
require 'active_git/events/db_create'
require 'active_git/events/db_update'
require 'active_git/events/db_delete'
require 'active_git/events/db_delete_all'
require 'active_git/events/file_event'
require 'active_git/events/file_save'
require 'active_git/events/file_delete'
require 'active_git/events/folder_remove'
require 'active_git/active_record_extension'
require 'active_git/configuration'
require 'active_git/commands'
require 'active_git/inflector'

module ActiveGit
  extend Commands

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end

  def self.models
    @models ||= []
  end

  def self.repository
    @repository = GitWrapper::Repository.new(ActiveGit.configuration.working_path) if @repository.nil? || @repository.location != ActiveGit.configuration.working_path
    @repository
  end

  def self.synchronize(*events)
    if @batch_mode
      enqueue events
    else
      Synchronizer.synchronize events
    end
  end

  def self.batch(&block)
    @batch_mode = true
    begin
      yield
      Synchronizer.synchronize @events
      @events.clear
    ensure
      @batch_mode = false
    end
  end

  private

  def self.enqueue(*events)
    @events = (@events || []) + events
  end

end

ActiveRecord::Base.send :extend, ActiveGit::ActiveRecord::ClassMethods