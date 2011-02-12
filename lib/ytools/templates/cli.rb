require 'optparse'
require 'ytools/basecli'
require 'ytools/errors'
require 'ytools/templates/executor'

module YTools::Templates
  class CLI < YTools::BaseCLI
    protected
    def execute(args)
      yaml_object = if args.length != 0
                      YTools::YamlObject.from_files(args)
                    else
                      YTools::YamlObject.new
                    end

      template = options[:expression]
      if template.nil?
        File.open(template, 'r') { |f| template = f.read}
      end
      
      if options[:literal]
        yaml_object.merge(YAML::load(options[:literal]))
      end

      executor = Executor.new(template, yaml_object)

      if options[:debug]
        STDERR.puts yaml_object
      end
      
      executor.write!(options[:output])
    end

    def parse(args)
      OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename($0)} [OPTIONS] YAML_FILES"
        opts.separator <<EOF
Description:
    This tool uses an ERB template file and a set of YAML files to
    generate a merged file.  For convenience, all of the keys in
    hashes in regular YAML can work like methods in the ERB templates.
    Thus, the YAML "{ 'a' : {'b' : 3 } }" could be used in an 
    ERB template with "<%= a.b %>" instead of the more verbose hash 
    syntax.  Indeed, the root hash values can only be accessed by
    those method attributes, because the root YAML context object
    is simply assumed.

    It accepts multiple yaml files, and will merge their contents in the
    order in which they are given.  Thus, files listed later, if their
    keys conflict with ones listed earlier, override the earlier listed
    values.  If you pass in files that don't exist, no error will be 
    raised unless the '--strict' flag is passed.

    Check out the '--examples' flag for more details.

Options:
EOF
        opts.on('-t', '--template ERB',
                "The ERB template file to use for generation") do |t|
          options[:template] = t
        end
        opts.on('-e', '--expression EXPR',
                "The ERB expression to use for generation",
                "overrides --template") do |e|
          options[:expression] = e
        end
        opts.on('-l', '--literal STRING',
                "Evaluate a literal string in addition",
                "to any file paths") do |l|
          options[:literal] = l
        end
        opts.on('-o', '--output FILE',
                "Write the generated output to a file instead",
                "of STDOUT") do |o|
          options[:output] = o
        end
        opts.on('-s', '--strict',
                "Checks to make sure all of the YAML files",
                "exist before proceeding.") do |s|
          options[:strict] = true
        end
        opts.separator ""
        
        opts.on('--examples',
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
      if options[:expression].nil? && options[:template].nil?
        raise YTools::ConfigurationError.new("No template expression or file was indicated")
      end

      if options[:expression].nil? && !File.exists?(options[:template])
        raise YTools::ConfigurationError.new("Unable to locate the template file: #{options[:template]}")
      end

      if options[:output] &&
          !File.exists?(File.dirname(options[:output]))
        raise YTools::ConfigurationError.new("The output directory doesn't exist: #{option[:output]}")
      end

      if args.length == 0 && options[:literal].nil?
        raise YTools::ConfigurationError.new("No YAML files were given")
      end

      if options[:strict]
        args.each do |file|
          if !File.exists?(file)
            raise YTools::ConfigurationError.new("Unable to locate YAML file: #{file}")
          end
        end
      end
    end
  end
end
