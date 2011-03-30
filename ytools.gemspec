# -*- encoding: utf-8 -*-
begin
  require 'rubygems'
  require 'choosy'
  require 'rake'
rescue LoadError
  # Pass
end

Gem::Specification.new do |gem|
  gem.name           = 'ytools'
  gem.version        = Choosy::Version.load(:file => __FILE__, :relpath => 'lib').to_s
  gem.platform       = Gem::Platform::RUBY
  gem.executables    = %W{ypath ytemplates}
  gem.summary        = 'For reading or writing configuration files using yaml.'
  gem.description    = 'Installs the ypath tool for reading YAML files using an XPath-like syntax. Installs the ytemplates tool for turning YAML-based configuration files into other files using erb temlates.'
  gem.email          = ['madeonamac@gmail.com']
  gem.authors        = ['Gabe McArthur']
  gem.homepage       = 'http://github.com/gabemc/ytools'
  gem.files          = FileList["[A-Z]*", "{bin,lib,spec}/**/*"]
    
  gem.add_dependency 'choosy', '>= 0.4.3'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'autotest'
  gem.add_development_dependency 'autotest-notification'
  gem.add_development_dependency 'ZenTest'

  gem.required_rubygems_version = ">= 1.3.6"
  gem.require_path = 'lib'
end
