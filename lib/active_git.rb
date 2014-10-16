require 'rugged'
require 'class_config'
require 'logger'
require 'json'
require 'timeout'

Dir.glob(File.expand_path(File.join('..', File.basename(__FILE__, '.rb'), '*.rb'), __FILE__)).sort.each { |f| require f }

module ActiveGit

  extend ClassConfig

  attr_config :logger, Logger.new(STDOUT)
  attr_config :lock_timeout, 60
  
end