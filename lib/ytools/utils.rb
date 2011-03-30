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

    def self.stdin?
      begin
        require 'fcntl'
        STDIN.fcntl(Fcntl::F_GETFL, 0) == 0  && !$stdin.tty?
      rescue
        $stdin.stat.size != 0
      end
    end
  end
end
