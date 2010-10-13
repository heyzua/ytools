require 'ytools/errors'

module YTools::Path

  Token = Struct.new(:path, :offset, :length, :type) do
    def value
      case type
        when :path_separator then '/'
        when :path_part then path # We cheat and put in the actual
                                  # value of the path part here, 
                                  # because we don't care about the offset
        when :lbrace then '['
        when :rbrace then ']'
        when :number then path[offset, length].to_i
        else raise YPath::PathError("Unrecognized token type!!!!")
      end
    end
  end
  
  class Lexer
    attr_reader :offset, :path

    def initialize(path)
      @path = path
      @offset = 0
      @buffer = []
    end

    def [](index)
      if offset + index >= path.length
        nil
      else
        @path[offset + index]
      end
    end

    def next
      if @buffer.length > 0
         @buffer.pop
      else
        token
      end
    end

    def peek(count=nil)
      count ||= 0

      if count >= @buffer.length
        (@buffer.length - count).downto(0) do
          @buffer.push(token)
        end
      end

      @buffer[count]
    end

    def has_next?
      !peek.nil?
    end

    private
    def token
      return nil if offset >= path.length

      case @path[offset]
        when ?/ then path_separator
        when ?[ then lbrace
        when ?] then rbrace
        when ?- then path_part
        when ?0..?9 then number
        else path_part
      end
    end

    def path_separator
      tok = Token.new(path, offset, 1, :path_separator)
      @offset += 1
      tok
    end

    def lbrace
      tok = Token.new(path, offset, 1, :lbrace)
      @offset += 1
      tok
    end

    def rbrace
      tok = Token.new(path, offset, 1, :rbrace)
      @offset += 1
      tok
    end

    def number
      starting_offset = offset

      while offset < path.length
        case path[offset]
          when ?0..?9 then @offset += 1
          else break
        end
      end

      Token.new(path, starting_offset, offset - starting_offset, :number)
    end

    def path_part
      starting_offset = offset
      in_bar = false
      str = ""

      while offset < path.length
        case path[offset]
        when ?\\
          if offset + 1 >= path.length
            raise YTools::PathError.new("Last character in a path cannot be a '\\' character: '#{path}'")
          end

          lookahead = path[offset + 1]
          case lookahead
          when ?[ , ?] , ?| , ?\ , ?/
            str << lookahead
            @offset += 2
          else
            raise YTools::PathError.new("Unescaped backslash character at position #{offset} in '#{path}'")
          end
        when ?| 
          in_bar = !in_bar
          @offset += 1
        when ?/ 
          if in_bar
            str << ?/
            @offset += 1
          else
            return path_or_number(str, starting_offset, offset - starting_offset)
          end
        when ?[ , ?] , ?@ then
          return path_or_number(str, starting_offset, offset - starting_offset)
        else 
          if !path[offset].nil?
            str << path[offset]
            @offset += 1
          end
        end
      end

      if in_bar
        raise YTools::PathError.new("There was no closing bar '|' character in the path '#{path}'")
      end

      return path_or_number(str, starting_offset, offset - starting_offset)
    end

# FIXME: there's a bug in here somewhere about the offset for numbers/paths.

    def path_or_number(str, start, length)
      i = str.to_i
      if i == 0
        return Token.new(str, start, length, :path_part)
      elsif i.to_s == str
        return Token.new(str, 0, length, :number)
      else
        return Token.new(str, start, length, :path_part)
      end
    end
  end # PathLexer  
end
