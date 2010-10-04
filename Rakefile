$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift File.expand_path("../spec", __FILE__)

require 'fileutils'
require 'rake'
require 'rubygems'
require 'spec/rake/spectask'
require 'ytools/version'

task :default => :spec

desc "Run the RSpec tests"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['-b', '-c', '-f', 'p']
  t.fail_on_error = false
end

desc "Deploys the gem to rubygems.org"
task :gem => :release do
  system("gem build ytools.gemspec")
#  system("gem push ytool-#{YTool::Version.to_s}.gem")
end

desc "Does the full release cycle."
task :deploy => [:gem, :clean] do
end

desc "Cleans the gem files up."
task :clean do
  FileUtils.rm(Dir.glob('*.gemspec'))
  FileUtils.rm(Dir.glob('*.gem'))
end
