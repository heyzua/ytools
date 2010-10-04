
module YTools
  class YamlObject
    attr_reader :ypath, :yroot, :hash

    def initialize(hash, root=nil, ypath=nil)
      @hash = hash.dup
      @ypath = ypath || '/'
      @methods = {}
      @yroot = root || self

      merge(hash)
    end

    def merge(hash)
      hash.each do |key, value|
        add_entry(key, value)
      end
    end
    
    def method_missing(sym, *args, &block)
      method_name = sym.to_s
      hash_key = @methods[method_name]

      if hash_key.nil?
        raise YTools::PathError.new("Unable to locate attribute '#{relative_ypath}/#{method_name}'")
      else
        @hash[hash_key]
      end
    end

    def [](key)
      value = @hash[key]
      if value.nil?
        raise YTools::PathError.new("Unable to locate key \"#{relative_ypath}@['#{key}']\"")
      end
      value
    end

    def []=(key, value)
      add_entry(key, value)
    end

    def to_s
      @hash.to_s
    end

    private
    def relative_ypath
      if ypath == '/'
        ''
      else
        ypath
      end
    end

    def add_entry(key, value)
      method_name = key.to_s.gsub(/-/, '_').gsub(/\./, '_')
      child_path = if method_name =~ /(@|\/|[|])/
                     "|#{key}|"
                   elsif key =~ /(\.|-)/
                     key
                   else
                     method_name
                   end
      hash_key = @methods[method_name]

      if hash_key.nil? # The item hasn't been defined yet
        value = hashify(value, "#{relative_ypath}/#{child_path}")
        @methods[method_name] = key
        @hash[key] = value
      else # The item is already defined
        original_value = @hash[hash_key]
        
        if original_value.is_a?(YamlObject) && value.is_a?(Hash)
          original_value.merge(value)
        elsif !value.is_nil?
          @hash[key] = hashify(value, "#{relative_ypath}/#{child_path}")
        end
      end
    end

    def hashify(obj, hash_path)
      if obj.is_a?(Hash)
        obj = YamlObject.new(obj, yroot, hash_path)
      elsif obj.is_a?(Array)
        0.upto(obj.length - 1).each do |i|
          obj[i] = hashify(obj[i], "#{hash_path}[#{i}]")
        end
      end
      obj
    end
  end
end
