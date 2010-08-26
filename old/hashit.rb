require 'erb'

# This is a class that turns yaml into objects
class Hashit

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

  def print_value(value, keys, &block)
    if value.is_a?(Hashit)
      value.traverse(keys.dup, &block)
    elsif (value.is_a?(String) || value.is_a?(Numeric)) && keys.empty?
      yield value.to_s.strip
    end
    # Don't do anything with arrays or the keys aren't empty -- path is actually malformed
  end
end
