require 'ytools/errors'
require 'ytools/utils'
require 'choosy'

module YTools
  class BaseCLI
    def initialize(args)
      @args = args.dup
    end

    def execute!
      tail(command).execute!(@args)
    end

    def parse(propagate=nil)
      tail(command).parse!(@args, propagate)
    end

    def command
      # overridden
    end

    protected
    def tail(command)
      command.alter do
        string :literal, "Evaluate a literal string in addition to any file paths."
        boolean :strict, "Checks to make sure all of the YAML files exist before proceeding."
        boolean :examples, "Show some examples on how to use the path syntax." do
          validate do |show, options|
            if show
              YTools::Utils.print_example(File.join(File.dirname(__FILE__), command.name.to_s.gsub(/^y/, '')))
            end
          end
        end
        boolean_ :debug, "Prints out the merged YAML as a ruby object to STDERR."
        version Choosy::Version.new(File.join(File.dirname(__FILE__), '..', 'VERSION.yml'))
        help
        
        arguments do
          metaname 'YAML_FILES'
          count :at_least => 0

          validate do |files, options|
            if files.length == 0 && options[:literal].nil? && !YTools::Utils.stdin?
              die "no YAML files given as arguments"
            end

            begin
              yaml_object = YTools::YamlObject.from_files(files, options[:strict])
              if options[:literal]
                yaml_object.merge(YAML::load(options[:literal]))
              end
              if YTools::Utils.stdin?
                yaml_object.merge(YAML::load(STDIN.read))
              end
              options[:yaml_object] = yaml_object
            rescue Exception => e
              if options[:debug]
                STDERR.puts e.stacktrace
              end
              die e.message
            end
          end
        end
      end

      command
    end
  end
end
