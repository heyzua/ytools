require 'ytools/errors'
require 'ytools/basecli'
require 'ytools/templates/executor'
require 'rubygems'
require 'choosy'

module YTools::Templates
  class CLI < YTools::BaseCLI
    def command
      Choosy::Command.new :ytemplates do
        executor Executor.new
        printer :standard, :max_width => 80

        heading 'Description:'
        para 'This tool uses an ERB template file and a set of YAML files to generate a merged file.  For convenience, all of the keys in hashes in regular YAML can work like methods in the ERB templates. Thus, the YAML "{ \'a\' : {\'b\' : 3 } }" could be used in an ERB template with "<%= a.b %>" instead of the more verbose hash syntax.  Indeed, the root hash values can only be accessed by those method attributes, because the root YAML context object is simply assumed.'
        para "It accepts multiple yaml files, and will merge their contents in the order in which they are given.  Thus, files listed later, if their keys conflict with ones listed earlier, override the earlier listed values.  If you pass in files that don't exist, no error will be raised unless the '--strict' flag is passed."
        para "Check out the '--examples' flag for more details."

        heading 'Options:'
        file :template, "The ERB template file to use for generation" do
          required
          depends_on :examples
        end
        string :output, "Write the generated output to a file instead of STDOUT" do
          validate do |path, options|
            if !File.exists?(File.dirname(options[:output]))
              die "The output directory doesn't exist: #{option[:output]}"
            end
          end
        end
      end
    end
  end # CLI
end
