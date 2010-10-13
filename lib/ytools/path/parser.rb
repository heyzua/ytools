require 'ytools/errors'
require 'ytools/path/lexer'

module YTools::Path

=begin
Yaml Path Spec:
---------------

yaml_path:
    child_selector (child_selector)* <-- '/' path_node is a root
  | path_node (child_selector)*
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
    LBRACE NUMBER RBRACE
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
      selector = nil

      if @lexer.has_next?
        selector = root_selector
      end

      while @lexer.has_next?
        selector.chain(child_selector)
      end

      selector
    end

    private
    def root_selector
      if @lexer.peek.type == :path_separator
        subselector = child_selector
        if subselector.is_a?(ChildSelector)
          RootSelector.new.chain(subselector)
        else
          subselector
        end
      else
        path_node(false)
      end
    end

    def child_selector
      slash = @lexer.next

      if slash.nil? || slash.type != :path_separator
        raise ParseError.new("Missing a path separator '/'", slash)
      end

      if @lexer.peek.nil?
        raise ParseError.new("Unfinished child path expression", slash)
      end

      if @lexer.peek.type == :path_separator
        @lexer.next # Pop off the separator
        path_node(true)
      else
        path_node(false)
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
        sel.chain(index_selector)
      end

      sel
    end

    def index_selector
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
