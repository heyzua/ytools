require 'ytools/errors'
require 'ytools/path/lexer'

module YTools::Path

=begin
Yaml Path Spec:
---------------

yaml_path:
    path_node (child_selector)*
  | child_selector+
  ;

child_selector:
    '/'  path_node
  | '//' path_node
  ;

path_node:
    PATH_PART index?
  | NUMBER index?
  ;

index:
    LBRACE number RBRACE
  ;

=end

  class ParseError < Exception
    attr_reader :token

    def initialize(message, token)
      super(message)
      @token = token
    end
  end

  class Parser

    def initialize(path)
      @lexer = Lexer.new(path)
      @path = path
    end

    def parse!
      tok = @lexer.peek
      selector = nil

      while tok != nil
        if selector.nil?
          selector = read_root
          tok = @lexer.peek
        end

        if !tok.nil? && tok.type != :path_separator
          raise ParseError("Unrecognized path separator, expected '/': #{tok.value}", tok)
        end

        path_selector
      end

      selector
    end

    private
    def read_root
      puts @lexer.peek(1)
      if @lexer.peek.type == :path_separator
        next_slash = @lexer.peek(1)

        if !next_slash.nil? && next_slash.type == :path_separator
          path_selector
        else
          root = RootSelector.new
          p = path_selector
          root.chain(p)
          root
        end
      else
        path_node
      end
    end

    def path_selector
      slash = @lexer.next

      if @lexer.peek.type == :path_separator
        path_node(true)
      else
        path_node
      end
    end

    def path_node(descendant=nil)
      node = @lexer.next
      if node.type != :number && node.type != :path_part
        raise ParseError.new("Unexpected path node type, number or string only", node)
      end

      sel = if descendant
              DescendantSelector.new(node.value)
            else
              ChildSelector.new(node.value)
            end

      if !@lexer.peek.nil? && @lexer.peek.type == :lbrace
        sel.chain(index)
      end

      sel
    end

    def index
      lbrace = @lexer.next

      number = @lexer.next
      if number.nil?
        raise ParseError.new("Missing number in unclosed index selector", lbrace)
      elsif number.type != :number
        raise ParseError.new("Only numbers are allowed in indices", lbrace)
      end
      
      rbrace = @lexer.next
      if rbrace.nil?
        raise ParseError.new("Unclosed ']' for index selector", lbrace)
      elsif rbrace.type != :rbrace
        raise ParseError.new("Missing ']' character for index", rbrace)
      end

      IndexSelector.new(number.value)
    end
  end # Parser
end
