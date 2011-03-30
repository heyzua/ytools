#$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
#$LOAD_PATH.unshift File.expand_path("../spec", __FILE__)

require 'rubygems'
require 'fileutils'
require 'rake'
require 'rspec/core/rake_task'
require 'choosy/version'
require 'choosy/rake'

task :default => :spec

desc "Run the RSpec tests"
RSpec::Core::RakeTask.new

desc "Cleans the gem files up."
task :clean => ['gem:clean']
