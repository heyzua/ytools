require 'yaml'
require 'ytools/yaml_object'
require 'ytools/path/parser'

module YTools::Path

  class Executor
    attr_reader :path, :yaml_object

    def initialize(path, files)
      @path = path
      @yaml_object = retrieve_yaml(files)
    end

    def process!
      parser = Parser.new(path)
      selectors = parser.parse!

      found = selectors.select(yaml_object)
      if found.is_a?(YTools::YamlObject)
        show_yaml_object(found)
      elsif found.is_a?(Array)
        show_array(found)
      else
        found.to_s
      end
    end

    private
    def retrieve_yaml(files)
      yo = YTools::YamlObject.new
      files.each do |file|
        if File.exists?(file)
          contents = nil
          File.open(file, 'r') { |f| contents = f.read}
          yo.merge(YAML::load(contents))
        end
      end
      yo
    end

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
