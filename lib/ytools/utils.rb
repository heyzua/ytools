require 'optparse'
require 'ytools/errors'

module YTools
  module Utils
    def self.print_example(basedir)
      examples = File.join(basedir, 'examples.txt')
      File.open(examples, 'r') do |f|
        f.each_line do |line|
          puts line
        end
      end
      exit 0
    end

    def self.read_stdin
      begin
        input = $stdin.read_nonblock(1)
        input << $stdin.read
      rescue Exception => e
        nil
      end
    end
  end
end
