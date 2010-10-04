require 'ytools/yaml_object'

def attempting(&block)
  lambda &block
end

def attempting_to(&block)
  lambda &block
end

module YTools
  module YamlObjectHelper
    def yo(hash)
      YamlObject.new(hash, nil)
    end
  end
end
