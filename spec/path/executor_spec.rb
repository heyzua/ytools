require 'helpers'
require 'ytools/errors'
require 'ytools/yaml_object'
require 'ytools/path/executor'

module YTools::Path

  module ExecutorHelper
    def process(path, *files)
      real_files = []
      files.each do |file|
        real_files << File.join(File.dirname(__FILE__), 'yamls', file)
      end

      yaml_object = YTools::YamlObject.from_files(real_files)
      Executor.new(path, yaml_object).process!
    end
  end

  describe "Executor" do
    include ExecutorHelper

    it "should be able to find a simple string in a yaml file" do
      process('/a/b', '1.yml').should eql("this")
    end

    it "should be able to find a numebr in the yaml file" do
      process('/a/b', '2.yml').should eql('42')
    end

    it "should be able to find an indexed element" do
      process('/a/b[2]', '3.yml').should eql('blah')
    end

    it "should be able to find descendant selectors" do
      process('/a//c[2]', '4.yml').should eql('2')
    end

    it "should be able to print all the elements in a list" do
      process('/a//c', '4.yml').should eql("0\n1\n2\n3")
    end

    it "should be able to pull out the keys for a hash" do
      process('/a', '5.yml').should eql("b\nc\nd")
    end

    it "should be able to pull out a descendant selector with inner hashes" do
      process('/a//b', '6.yml').should eql("c\nd\ne")
    end
  end
end
