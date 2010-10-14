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

    def select(yaml)
      inner_select(yaml, [])
    end

    private
    def inner_select(yaml, results)
      yaml.yhash.each do |key, value|
        if key == match
          key_select(value, results)
        end
        value_select(value, results)
      end
      
      if results.length == 1
        results[0]
      else
        results
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

    def value_select(value, results)
      if value.is_a?(YTools::YamlObject)
        inner_select(value, results)
      elsif value.is_a?(Array)
        value.each do |v|
          if v.is_a?(YTools::YamlObject)
            inner_select(v, results)
          end
        end
      end
    end
  end
end
