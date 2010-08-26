require 'yaml'

module YTools

  class YReader
    def read(yaml_files)
      root = {}

      yaml_files.each do |yaml_file|
        if File.exists?(yaml_file)
          yaml = YAML::load(File.read(yaml_file))
          if !yaml.is_a?(Hash)
            raise PathError.new("The yaml file wasn't a hash!")
          end

          
        end
      end
    end
  end
end
