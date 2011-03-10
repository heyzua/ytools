require 'ytools/yaml_object'
require 'ytools/path/parser'

module YTools::Path
  class Executor
    attr_reader :selector, :yaml_object

    def initialize(path=nil, yaml_object=nil)
      @selector = Parser.new(path).parse! if path
      @yaml_object = yaml_object
    end

    def execute!(yaml_files, options)
      @yaml_object = options[:yaml_object]

      if options[:debug]
        STDERR.puts @yaml_object.to_s
      end

      @selector = options[:selector]
      output = process!
      puts output if !output.empty?
    end

    def process!
      found = @selector.select(yaml_object)
      if found.is_a?(YTools::YamlObject)
        show_yaml_object(found)
      elsif found.is_a?(Array)
        show_array(found)
      else
        found.to_s
      end
    end

    private
    def show_yaml_object(found)
      output = ""
      first = true
      found.yhash.each_key do |key|
        if first
          first = false
        else
          output << "\n"
        end
        output << key.to_s
      end
      output
    end

    def show_array(found)
      output = ""
      first = true
      found.each do |found|
        if first
          first = false
        else
          output << "\n"
        end
        output << found.to_s 
      end
      output
    end
  end
end
