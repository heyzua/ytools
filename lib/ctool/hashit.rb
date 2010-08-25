require 'erb'

# This is a class that turns yaml into objects
class Hashit
  def initialize(hash)
    @hash = hash.dup
    merge(hash)
  end

  def merge(hash)
    hash.each do |k, v|
      varname = "@#{k.to_s}".gsub(/-/, '_').gsub(/\./, '_')

      if self.instance_variable_defined?(varname)
        value = self.instance_variable_get(varname)
        if value.is_a?(Hashit) && v.is_a?(Hash)
          value.merge(v)
        elsif v
          self.instance_variable_set(varname, v)
          @hash[k] = hashify(v)
        end
      else
        v = hashify(v)

        self.instance_variable_set(varname, v)
        @hash[k] = v
        self.class.send(:define_method, k.to_sym, proc {self.instance_variable_get varname})
      end
    end
  end

  def [](key)
    @hash[key]
  end

  def get_binding
    binding
  end

  def find_each(path, &block)
    parts = PathParser.scan(path)
    traverse(parts, &block)
  end

  def self.from_files(yaml_files)
    values = Hashit.new({})
    yaml_files.reverse.each do |yaml_file|
      if File.exists?(yaml_file)
        yaml = YAML::load(File.read(yaml_file))
        if !yaml.is_a?(Hash)
          raise PathError.new("The yaml file wasn't a hash!")
        end

        values.merge(yaml)
      end
    end
    values
  end

  def traverse(keys, &block)
    if keys.nil? || keys.empty? # No more paths
      @hash.keys.sort.each do |key|
        yield key.to_s.strip
      end
    end

    current_key = keys.shift
    return if current_key.nil?

    if current_key =~ /(.*)\[\]$/
      return if !self.respond_to?($1.to_sym)
      value = self.send($1.to_sym)
      if value.is_a?(Array)
        value.each do |e|
          print_value(e, keys, &block)
        end
      end
    elsif current_key =~ /(.*)\[(\d+)\]$/
      return if !self.respond_to?($1.to_sym)
      value = self.send($1.to_sym)
      if value.is_a?(Array)
        print_value(value[$2.to_i], keys, &block)
      end
    else
      return if !self.respond_to?(current_key.to_sym)
      print_value(self.send(current_key.to_sym), keys, &block)
    end
  end

  private
  def hashify(obj)
    if obj.is_a?(Hash)
      obj = Hashit.new(obj)
    elsif obj.is_a?(Array)
      0.upto(obj.length - 1).each do |i|
        obj[i] = hashify(obj[i])
      end
    end
    obj
  end

  def print_value(value, keys, &block)
    if value.is_a?(Hashit)
      value.traverse(keys.dup, &block)
    elsif (value.is_a?(String) || value.is_a?(Numeric)) && keys.empty?
      yield value.to_s.strip
    end
    # Don't do anything with arrays or the keys aren't empty -- path is actually malformed
  end
end
