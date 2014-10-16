require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:spec) do |t|
  t.libs << 'spec'
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = false
end

task default: :spec

desc 'Pry console'
task :console do
  require 'active_git'
  require 'pry'
  ARGV.clear
  Pry.start
end