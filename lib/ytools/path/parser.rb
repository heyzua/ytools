require 'ytools/errors'
require 'ytools/path/lexer'

module YTools::Path

  class Parser

    def initialize(path)
      @lexer = PathLexer(path)
    end

    def parse!

    end
  end # Parser
end
