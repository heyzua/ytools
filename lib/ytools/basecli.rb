require 'optparse'
require 'ytools/errors'
require 'ytools/version'

module YTools

  class BaseCLI
    attr_reader :options, :args

    def initialize(args)
      @args = args
      @options = {}
    end

    def execute!
      begin
        sargs = args.dup
        parse(sargs)
        validate(sargs)
        execute(sargs)
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

    protected
    def parse(args)
      # To override
    end

    def validate(args)
      # To override
    end

    def execute(args)
      # To override
    end

    def print_version
      puts "#{File.basename($0)} version: #{YTools::Version.to_s}"
      exit 0
    end

    def print_examples(basedir)
      examples = File.join(basedir, 'examples.txt')
      File.open(examples, 'r') do |f|
        f.each_line do |line|
          puts line
        end
      end
      exit 0
    end

    def print_error(e)
      STDERR.puts "ERROR: #{File.basename($0)}: #{e}"
      STDERR.puts "ERROR: #{File.basename($0)}: Try '--help' for more information"
      exit 1
    end
  end
end
