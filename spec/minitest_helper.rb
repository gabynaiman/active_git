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

Country = Struct.new :id, :name


class Minitest::Spec
  REPO_PATH = File.expand_path '../tmp/repository', __FILE__

  before do
    FileUtils.rm_rf REPO_PATH
    Rugged::Repository.init_at REPO_PATH
  end

  let(:db) { ActiveGit::Database.new REPO_PATH }

  def repo
    Rugged::Repository.new REPO_PATH
  end

  def silent
    yield
  rescue
    # Silenced error
  end
end