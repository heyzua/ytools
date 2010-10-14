require 'optparse'
require 'ytools/basecli'
require 'ytools/errors'
require 'ytools/path/executor'

module YTools::Path
  class CLI < YTools::BaseCLI
    protected 
    def execute(sargs)
      begin
        executor = Executor.new(options[:path], sargs)

        if options[:debug]
          STDERR.puts executor.yaml_object
        end

        puts executor.process!
      rescue YTools::Path::ParseError => e
        print_path_error(e)
      end
    end

    def parse(args)
      OptionParser.new do |opts| 
        opts.banner = "Usage: #{File.basename($0)} [OPTIONS] YAML_FILES"
        opts.separator <<EOF
Description:
    This tool uses a kind of XPath syntax for locating and printing elements
    from within YAML files.  Check out the '--examples' flag for details
    on the exact path syntax.

    It accepts multiple yaml files, and will merge their contents in the
    order in which they are given.  Thus, files listed later, if their
    keys conflict with ones listed earlier, override the earlier listed
    values.  If you pass in files that don't exist, no error will be 
    raised unless the '--strict' flag is passed.

Options:
EOF

        opts.on('-p', '--path PATTERN',
                "The pattern to use to access the",
                "configuration.") do |p|
          options[:path] = p
        end
        opts.on('-s', '--strict',
                "Checks to make sure all of the YAML files",
                "exist before proceeding.") do |s|
          options[:strict] = true
        end
        opts.separator ""
        
        opts.on('-e', '--examples',
                "Show some examples on how to use the",
                "path syntax.") do
          print_examples(File.dirname(__FILE__))
        end
        opts.on('-v', '--version',
                "Show the version information") do |v|
          print_version
        end
        opts.on('-d', '--debug',
                "Prints out the merged yaml as a",
                "ruby object to STDERR.") do |d|
          options[:debug] = true
        end
        opts.on('-h', '--help',
                "Show this help message.") do
          puts opts
          exit 0
        end
      end.parse!(args)
    end

    def validate(args)
      if options[:path].nil?
        raise YTools::ConfigurationError.new("The path expression was empty.")
      end
      if args.length == 0
        raise YTools::ConfigurationError.new("No YAML files given as arguments")
      end

      if options[:strict]
        args.each do |arg|
          if !File.exists?(arg)
            raise YTools::ConfigurationError.new("Non-existant YAML file: #{arg}")
          end
        end
      end
    end

    def print_path_error(e)
      STDERR.puts "ERROR: Path error: #{e.token.path}"
      spacer = "ERROR:             "
      e.token.offset.downto(1) do 
        spacer << " "
      end
      spacer << "^"
      STDERR.puts spacer
      print_error("Path expression parsing error - #{e.message}")
    end
  end # CLI
end
