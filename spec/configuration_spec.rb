require 'spec_helper'

describe ActiveGit::Configuration do

  before :each do
    @working_path = ActiveGit.configuration.working_path
    @bare_path = ActiveGit.configuration.bare_path
    @logger = ActiveGit.configuration.logger
  end

  after :each do
    ActiveGit.configuration.working_path = @working_path
    ActiveGit.configuration.bare_path = @bare_path
    ActiveGit.configuration.logger = @logger
  end

  it 'default sync_batch_size' do
    ActiveGit.configuration.sync_batch_size.should eq 10000
  end

  it 'set sync_batch_size' do
    ActiveGit.configuration.sync_batch_size = 100
    ActiveGit.configuration.sync_batch_size.should eq 100
  end

  it 'set working_path with string' do
    ActiveGit.configuration.working_path = "/path_to_test"
    ActiveGit.configuration.working_path.should eq "/path_to_test"
  end

  it 'set working_path with block' do
    ActiveGit.configuration.working_path = lambda do
      path_home = '/home'
      "#{path_home}/path_to_test"
    end
    ActiveGit.configuration.working_path.should eq "/home/path_to_test"
  end

  it 'set bare_path with string' do
    ActiveGit.configuration.bare_path = "/path_to_test"
    ActiveGit.configuration.bare_path.should eq "/path_to_test"
  end

  it 'set bare_path with block' do
    ActiveGit.configuration.bare_path = lambda do
      path_home = '/home'
      "#{path_home}/path_to_test"
    end
    ActiveGit.configuration.bare_path.should eq "/home/path_to_test"
  end

  it 'get default logger' do
    ActiveGit.configuration.logger.should be_a Logger
  end

  it 'set logger' do
    logger = Logger.new($stdout)
    ActiveGit.configuration.logger.should_not eq logger
    ActiveGit.configuration.logger = logger
    ActiveGit.configuration.logger.should eq logger
  end

end