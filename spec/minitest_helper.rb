require 'coverage_helper'
require 'active_git'
require 'minitest/autorun'
require 'turn'
require 'pry-nav'

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
  CLONE_PATH = File.expand_path '../tmp/clone', __FILE__
  BARE_PATH = File.expand_path '../tmp/bare.git', __FILE__

  before do
    FileUtils.rm_rf BARE_PATH
    FileUtils.rm_rf REPO_PATH
    FileUtils.rm_rf CLONE_PATH

    Rugged::Repository.init_at BARE_PATH, :bare
    Rugged::Repository.clone_at BARE_PATH, REPO_PATH
    Rugged::Repository.clone_at BARE_PATH, CLONE_PATH
  end

  let(:db) { ActiveGit::Database.new REPO_PATH }

  def repo
    Rugged::Repository.new REPO_PATH
  end

  let(:clone_db) { ActiveGit::Database.new CLONE_PATH }

  def clone_repo
    Rugged::Repository.new CLONE_PATH
  end

  def bare_repo
    Rugged::Repository.bare BARE_PATH
  end

  def silent
    yield
  rescue
    # Silenced error
  end
end