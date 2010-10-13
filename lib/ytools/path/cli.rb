require 'optparse'
require 'yaml'
require 'ytools/version'
require 'ytools/errors'

module YTools::Path

  class CLI
    attr_reader :options, :args

    def initialize(args)
      @args = args
    end

    def execute!
      begin
        sargs = args.dup
        parse(sargs)
        validate(sargs)

        
      rescue SystemExit => e
        raise
      rescue YTools::ConfigurationError => e
        print_error(e.message)
      rescue OptionParser::InvalidOption => e
        print_error(e.message)
      rescue Exception => e
        STDERR.puts e.backtrace
        print_error(e.message)
      end
    end

    def parse(args)
      @options ||= {}
      @option_parser ||= OptionParser.new do |opts| 
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
                "The pattern to use to access the configuration.") do |p|
          options[:path] = p
        end
        opts.on('-s', '--strict',
                "Checks to make sure all of the YAML files exist before proceeding.") do |s|
          options[:strict] = true
        end
        opts.separator ""
        
        opts.on('-e', '--examples',
                "Show some examples on how to use the path syntax.") do
          dir = File.dirname(__FILE__)
          examples = File.join(dir, 'examples.txt')
          File.open(examples, 'r') do |f|
            f.each_line do |line|
              puts line
            end
          end
          exit 0
        end
        opts.on('-v', '--version',
                "Show the version information") do |v|
          puts "#{File.basename($0)} version: #{CTool::Version.to_s}"
          exit 0
        end
        opts.on('-d', '--debug',
                     "Prints out the merged yaml as a ruby object to STDERR.") do |d|
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

    private
    def print_error(e)
      STDERR.puts "ERROR: #{File.basename($0)}: #{e}"
      STDERR.puts "ERROR: #{File.basename($0)}: Try '--help' for more information"
      exit 1
    end
  end # CLI
end
