# -*- encoding: utf-8 -*-
require File.expand_path('../lib/active_git/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = 'active_git'
  spec.version       = ActiveGit::VERSION
  spec.authors       = ['Gabriel Naiman']
  spec.email         = ['gabynaiman@gmail.com']
  spec.description   = 'Manage Database versions with Git'
  spec.summary       = 'Manage Database versions with Git'
  spec.homepage      = 'https://github.com/gabynaiman/active_git'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($\)
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # spec.add_dependency 'activerecord', '~> 3.2'
  # spec.add_dependency 'activerecord-import'
  # spec.add_dependency 'easy_diff'
  spec.add_dependency 'class_config'
  spec.add_dependency 'rugged', '0.21.0'


  spec.add_development_dependency 'bundler',          '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest',         '~> 4.7'
  spec.add_development_dependency 'turn',             '~> 0.9'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-nav'
  # spec.add_development_dependency 'database_cleaner', '~> 1.3'

  # if RUBY_ENGINE == 'jruby'
  #   spec.add_development_dependency 'activerecord-jdbcsqlite3-adapter'
  #   spec.add_development_dependency 'activerecord-jdbcpostgresql-adapter'
  # else
  #   spec.add_development_dependency 'sqlite3'
  #   spec.add_development_dependency 'pg'
  # end
end