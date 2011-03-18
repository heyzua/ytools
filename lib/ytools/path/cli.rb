require 'rubygems'
require 'choosy'
require 'ytools/basecli'
require 'ytools/path/executor'
require 'ytools/path/parser'

module YTools::Path
  class CLI < YTools::BaseCLI
    def command
      Choosy::Command.new :ypath do
        printer :standard, :max_width => 80
        executor Executor.new

        header 'Description:'
        para "This tool uses a kind of XPath syntax for locating and printing elements from within YAML files.  Check out the '--examples' flag for details on the exact path syntax."
        para "It accepts multiple yaml files, and will merge their contents in the order in which they are given.  Thus, files listed later, if their keys conflict with ones listed earlier, override the earlier listed values.  If you pass in files that don't exist, no error will be  raised unless the '--strict' flag is passed."

        header 'Option:'
        string :path, "The YAML Path pattern syntax to run against the input." do
          required
          depends_on :examples
          validate do |path, options|
            begin
              options[:selector] = YTools::Path::Parser.new(path).parse!
            rescue YTools::Path::ParseError => e
              if e.token.path == ""
                die "error parsing expression: #{e.message}"
              else
                die "error parsing expression: #{e.message}
    #{e.token.path}
    #{' ' * e.token.offset}^"
              end
            end
          end
        end

        string :literal, "Evaluate a literal string in addition to any file paths."
      end
    end
  end # CLI
end
