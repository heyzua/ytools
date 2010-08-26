require 'ytools/errors'

module YTools::YPath

  Token = Struct.new(:path, :offset, :length, :type) do
    def value
      case type
        when :path_separator then '/'
        when :path_part then path # We cheat and put in the actual value of the path part here, because we don't care about the offset
        when :at then '@'
        when :lbrace then '['
        when :rbrace then ']'
        when :number then path[offset, length].to_i
        when :string then path[offset, length]
        else raise YPath::PathError("Unrecognized token type!!!!")
      end
    end
  end
  
  class Lexer
    attr_reader :offset, :path

    def initialize(path)
      @path = path
      @offset = 0

      if path[offset] != ?/ 
        raise YTools::PathError.new("The path didn't start with a '/' character: #{path}")
      end
    end

    def [](index)
      if offset + index >= path.length
        nil
      else
        @path[offset + index]
      end
    end

    def next
      if offset >= path.length
        return nil
      end

      case @path[offset]
        when ?/ then path_separator
        when ?@ then at
        when ?[ then lbrace
        when ?] then rbrace
        when ?' then string
        when ?" then string
        when ?0..?9 then number
        else path_part
        # raise YTools::PathError.new("Unrecognized character '#{path[offset].chr}' at offset #{offset} in '#{path}'")
      end
    end

    private
    def path_separator
      tok = Token.new(path, offset, 1, :path_separator)
      @offset += 1
      tok
    end

    def at
      tok = Token.new(path, offset, 1, :at)
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

    def string
      starting_character = path[offset]
      @offset += 1
      starting_offset = offset # Exclude the first ['|"] character

      while path[offset] != starting_character && offset < path.length
        @offset += 1
      end

      if offset == path.length
        raise YTools::PathError.new("The string starting at position #{starting_offset} was not closed correctly in '#{path}'")
      end

      @offset += 1 # Consume the trailing ['|"] character

      Token.new(path, starting_offset, offset - starting_offset - 1, :string)
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
          when ?[ , ?] , ?| , ?\ , ?@ , ?/
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
            return Token.new(str, starting_offset, offset - starting_offset, :path_part)
          end
        when ?[ , ?] , ?@ then
          return Token.new(str, starting_offset, offset - starting_offset, :path_part)
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

      return Token.new(str, starting_offset, offset - starting_offset, :path_part)
    end
  end # PathLexer  
end
