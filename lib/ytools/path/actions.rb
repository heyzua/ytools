require 'ytools/errors'
require 'ytools/yaml_object'

module YTools::Path

  class ActionCommand
    attr_reader :chained
    alias :chain, :<<

    def chain(action)
      if chained.nil?
        chained = action
      else
        chained.chain(action)
      end
    end
  end

  class PathCommand < ActionCommand
    
    

  end
end
