#!/usr/bin/env ruby

require 'yaml'
require 'optparse'
require 'erb'
require File.join(File.dirname(__FILE__), 'hashit.rb')

args = ARGV.dup
options = {}
option_parser = OptionParser.new do |opts| 
  opts.banner = "Usage: #{File.basename($0)} [OPTIONS] YAML_FILES"
  opts.separator <<EOF
Description:
   Transforms a '.erb' file and one or more yaml files into
   a final output file.  The values in the yaml files are prioritized --
   those that come foremost in the list are valued more than those
   that come later in the list.

Options:
EOF

  opts.on('-o', '--output OUTPUT',
          "The output file") do |o|
    options[:output] = o
  end
  opts.on('-t', '--template ERB_TEMPLATE',
          "The erb template file") do |t|
    options[:template] = t
  end

  opts.on_tail('-h', '--help',
               "Show this help message") do 
    puts opts
    exit 0
  end
  opts.on_tail('--debug',
               "Prints out the merged yaml as a ruby object.") do |d|
    options[:debug] = true
  end
end.parse!(args)

if args.length == 0
  STDERR.puts "No YAML files given as arguments"
  exit 1
end
if options[:template].nil? || !File.exists?(options[:template])
  STDERR.puts "The template file doesn't exist: #{options[:template]}"
  exit 1
end

# Merge the yaml files
values = Hashit.from_files(args)

# Print the debug outptu
if options[:debug]
  require 'pp'
  pp values
end

# Use the template to generate the file
template = ERB.new(File.read(options[:template]))
output = template.result(values.get_binding)

if options[:output].nil?
  puts output
else
  File.open(options[:output], 'w') {|f| f.write(output)}
end
