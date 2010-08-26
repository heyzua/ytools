#!/usr/bin/env ruby

require 'yaml'
require 'optparse'
require File.join(File.dirname(__FILE__), 'hashit.rb')

args = ARGV.dup
options = {}


# Merge the yaml files
values = Hashit.from_files(args)

# Print the debug output
if options[:debug]
  require 'pp'
  pp values
end

values.find_each(options[:path]) do |value|
  puts value
end
