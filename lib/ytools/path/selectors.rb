require 'ytools/errors'
require 'ytools/yaml_object'

module YTools::Path

  class Selector
    attr_reader :subselector
    #alias :chain :<<

    def chain(selector)
      if !chained?
        @subselector = selector
      else
        @subselector.chain(selector)
      end
      self
    end

    def chained?
      !@subselector.nil?
    end
  end

  class ChildSelector < Selector
    attr_reader :child

    def initialize(child)
      @child = child
    end

    def select(yaml)
      if yaml.yhash.has_key?(child)
        value = yaml[child]
        if chained?
          subselector.select(value)
        else
          value
        end
      else
        nil
      end
    end
  end

  class IndexSelector < Selector
    attr_reader :index

    def initialize(index)
      @index = index
    end

    def select(array)
      if array.respond_to?(:[])
        value = array[index]
        if chained?
          subselector.select(value)
        else
          value
        end
      else
        nil
      end
    end
  end

  class RootSelector < Selector
    def select(yaml)
      if yaml.is_a?(YTools::YamlObject)
        value = yaml.yroot
        if chained?
          subselector.select(value)
        else
          value
        end
      else
        nil
      end
    end
  end

  class DescendantSelector < Selector
    attr_reader :match

    def initialize(match)
      @match = match
    end

    def select(element)
      results = []
      element_select(element, results)
      if results.length == 1
        results[0]
      else
        results
      end
    end

    private
    def element_select(element, results)
      if element.is_a?(YTools::YamlObject)
        hash_select(element, results)
      elsif element.is_a?(Array)
        element.each do |e|
          element_select(e, results)
        end
      end
    end

    def hash_select(yaml, results)
      yaml.yhash.each do |key, value|
        if key == match
          key_select(value, results)
        end
        element_select(value, results)
      end
    end

    def key_select(value, results)
      # Filter through the chain, if present
      if chained?
        nvalue = subselector.select(value)
        if !nvalue.nil?
          results << nvalue
        end
      else
        results << value
      end
    end
  end
end
