require 'erb'
require 'ytools/yaml_object'
require 'ytools/templates/yaml_object'

module YTools::Templates
  class Executor
    attr_reader :template, :yaml_object

    def initialize(template=nil, yaml_object=nil)
      @template = template
      @yaml_object = yaml_object
    end

    def execute!(yaml_files, options)
      @template = options[:erb]
      @yaml_object = options[:yaml_object]

      if options[:debug]
        STDERR.puts @yaml_object.to_s
      end
      
      write!(options[:output])
    end

    def write!(outfile)
      generator = ERB.new(template)
      output = generator.result(yaml_object.erb_binding)

      if outfile
        File.open(outfile, 'w') {|f| f.write(output)}
      else
        puts output
      end
    end
  end
end
