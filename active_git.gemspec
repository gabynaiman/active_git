# -*- encoding: utf-8 -*-
require File.expand_path('../lib/active_git/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = "active_git"
  s.version       = ActiveGit::VERSION
  s.authors       = ["Gabriel Naiman"]
  s.email         = ["gabynaiman@gmail.com"]
  s.description   = 'DB and GIT synchronization via ActiveRecord and GitWrapper'
  s.summary       = 'DB and GIT synchronization via ActiveRecord and GitWrapper'
  s.homepage      = 'https://github.com/gabynaiman/active_git'

  s.files         = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_dependency 'activerecord', '>= 3.0.0'
  s.add_dependency 'git_wrapper', '~> 1.1'
  s.add_dependency 'activerecord-import'
  s.add_dependency 'easy_diff'

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake"
  s.add_development_dependency 'rspec'
  s.add_development_dependency "simplecov"
  if RUBY_ENGINE == 'jruby'
    s.add_development_dependency 'activerecord-jdbcsqlite3-adapter'
    s.add_development_dependency 'activerecord-jdbcpostgresql-adapter'
  else
    s.add_development_dependency 'sqlite3'
    s.add_development_dependency 'pg'
  end
end
