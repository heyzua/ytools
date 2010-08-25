require 'ctool/path_parser'

module CTool

  describe "Path lexer" do
    
  end

  module PathParserHelper
    def parsing(path)
      return PathParser.scan(path)
    end
  end

  describe "Path parser" do
    include PathParserHelper

    it "should be able to pull out a single path part" do
      parsing('simple').should eql(['simple'])
    end

    it "should be able to pull out a more complicated path in parts" do
      parsing('simple.here').should eql(['simple', 'here'])
    end

    it "should be able to parse paths with '.'s in '|'s" do
      parsing('simple.|here.should|.work').should eql(['simple', 'here.should', 'work'])
    end


  end
end
