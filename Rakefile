$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift File.expand_path("../spec", __FILE__)

require 'fileutils'
require 'rake'
require 'rubygems'
require 'rspec/core/rake_task'
require 'ytools/version'

task :default => :spec

desc "Run the RSpec tests"
RSpec::Core::RakeTask.new

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name           = 'ytools'
    gem.version        = YTools::Version.to_s
    gem.executables    = %W{ypath ytemplates}
    gem.summary        = 'For reading or writing configuration files using YAML.'
    gem.description    = "Installs the ypath tool for reading YAML files using an XPath-like syntax.  Installs the ytemplates tool for writing ERB templates using YAML files as the template binding object."
    gem.email          = ['madeonamac@gmail.com']
    gem.authors        = ['Gabe McArthur']
    gem.homepage       = 'http://github.com/gabemc/ytools'
    gem.files          = FileList["[A-Z]*", "{bin,lib,spec}/**/*"]
    
    gem.add_dependency             'choosy', '>=0.2.5'
    gem.add_development_dependency 'rspec', '>=2.5.0'
  end
rescue LoadError
  puts "Jeweler or dependencies are not available.  Install it with: sudo gem install jeweler"
end

desc "Deploys the gem to rubygems.org"
task :gem => :release do
  system("gem build ytools.gemspec")
  system("gem push ytools-#{YTools::Version.to_s}.gem")
end

desc "Does the full release cycle."
task :deploy => [:gem, :clean] do
end

desc "Cleans the gem files up."
task :clean do
  FileUtils.rm(Dir.glob('*.gemspec'))
  FileUtils.rm(Dir.glob('*.gem'))
end
