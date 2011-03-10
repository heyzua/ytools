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
      @template = options[:template]
      @yaml_object = options[:yaml_object]

      if options[:debug]
        STDERR.puts @yaml_object.to_s
      end
      
      write!(options[:output])
    end

    def write!(outfile)
      tcontents = nil
      File.open(template, 'r') { |f| tcontents = f.read}

      generator = ERB.new(tcontents)
      output = generator.result(yaml_object.erb_binding)

      if outfile
        File.open(outfile, 'w') {|f| f.write(output)}
      else
        puts output
      end
    end
  end
end
