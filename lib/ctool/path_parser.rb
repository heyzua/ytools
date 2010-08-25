
module CTool
  class PathError < Exception
  end

  class Position
    attr_reader :offset, :length

    def initialize(path, offset, length)
      @path = path
      @offset = offset
      @length = length
    end

    def to_s
      @path[offset, length]
    end
  end

  class PathPart
    attr_reader :position

    def initialize(position)
      @position = position
    end
  end

  class IndexPathPart < PathPart
    attr_reader :index

    def initialize(position, index)
      super(position)
      @index = index
    end

    def set?
      !@index.nil?
    end
  end

  class PathLexer
    attr_reader :path, :offset

    def initialize(path)
      @path = path
      @offset = 0
    end

    def [](index)
      @path[index + offset]
    end

    def next
      # TODO
    end
  end

  class PathParser
    attr_reader :parts

    def initialize(path)
      @letters = path.scan(/./)
      @parts = []
    end

    def parse!
      while @letters.length > 0
        part = path_part(letters)
        if part.length > 0
          parts << part
        end
      end

      @parts
    end

    private
    def path_part(letters)
      part = []
      in_bar = false

      case @letters[0]
        when '.' then if in_bar
                        part << '.'
                      else
                        @letters.shift
                      end
        when '|' then if in_bar
                        @letters.shift
                        in_bar = false
                      else
                        @letters.shift
                        in_bar = true
                      end
        when '[' then
      end
    end

    def string_segment(part, in_bar)
      @letters.shift # '.'
      case @letters[0]
        when 
    end

    def self.scan(path)
      letters = path.scan(/./)
      parts = []

      while !letters.empty?
        part = next_path(letters, false)
        if part.length > 0
          parts << part
        end
      end

      parts
    end

    private
    def self.next_path(letters, in_bar)
      str = []

      while letters.length > 0
        letter = letters.shift
        break if letter == '.' && !in_bar
        if letter == '|'
          if in_bar
            break
          else
            in_bar = true
          end
        else
          str << letter
        end
      end

      str.join('')
    end
  end
end
