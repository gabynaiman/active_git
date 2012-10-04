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
  s.add_dependency 'git_wrapper', '>= 1.0.0'

  s.add_development_dependency 'rspec'
end
