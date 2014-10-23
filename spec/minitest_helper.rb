require 'coverage_helper'
require 'active_git'
require 'minitest/autorun'
require 'turn'
require 'pry-nav'
require 'fileutils'

Turn.config do |c|
  c.format = :pretty
  c.natural = true
  c.ansi = true
end

ActiveGit.configure do |config|
  config.logger.level = Logger::INFO
end

class Minitest::Spec
  REPO_PATH = File.expand_path '../tmp/repo', __FILE__
  OTHER_PATH = File.expand_path '../tmp/clone', __FILE__
  BARE_PATH = File.expand_path '../tmp/bare.git', __FILE__
  OTHER_BARE_PATH = File.expand_path '../tmp/other_bare.git', __FILE__

  before do
    Dir.glob(File.expand_path('../tmp/*', __FILE__)).each { |d| FileUtils.rm_rf d }

    Rugged::Repository.init_at BARE_PATH, :bare
    Rugged::Repository.init_at OTHER_BARE_PATH, :bare
    
    repo = Rugged::Repository.clone_at BARE_PATH, REPO_PATH
    repo.remotes.create 'other', OTHER_BARE_PATH

    other = Rugged::Repository.clone_at BARE_PATH, OTHER_PATH
    other.remotes.create 'other', OTHER_BARE_PATH
  end

  let(:db) { ActiveGit::Database.new REPO_PATH }

  def repo
    Rugged::Repository.new REPO_PATH
  end

  let(:other_db) { ActiveGit::Database.new OTHER_PATH }

  def other_repo
    Rugged::Repository.new OTHER_PATH
  end

  def bare_repo
    Rugged::Repository.bare BARE_PATH
  end

  def other_bare_repo
    Rugged::Repository.bare OTHER_BARE_PATH
  end

  def silent
    yield
  rescue
    # Silenced error
  end
end