require 'helpers'
require 'ytools/errors'
require 'ytools/path/lexer'
require 'ytools/path/parser'

module YTools::Path

  module PathParserHelper
    # Call private methods on the parser
    def pm(path, method)
      parser = Parser.new(path)
      parser.send(method)
    end

    def finding(yaml, path)
      parser = Parser.new(path)
      action = parser.parse!
      action.select(yaml)
    end
  end

  describe "Path Parser" do
    include YamlObjectHelper
    include PathParserHelper

    describe "index operations" do
      it "should fail when the number is nil" do
        attempting { pm("[", :index) }.should raise_error(ParseError, /Missing number/)
      end

      it "should fail when the index isn't a number" do
        attempting { pm("[not_a_number]", :index) }.should raise_error(ParseError, /Only numbers/)
      end

      it "should fail when the RBRACE isn't present" do
        attempting { pm("[1", :index) }.should raise_error(ParseError, /Unclosed/)
      end

      it "should fail when the final index token isn't an RBRACE" do
        attempting { pm("[1/", :index) }.should raise_error(ParseError, /Missing '\]'/)
      end

      it "should be able to pull an index selector" do
        pm("[23]", :index).index.should eql(23)
      end
    end


    describe "path node operations" do
      it "should be able to pull the node name" do
        pm("node", :path_node).child.should eql('node')
      end

      it "should be able to chain an index selector" do
        pm("node[1]", :path_node).subselector.index.should eql(1)
      end
    end

    describe "root operations" do
      it "should be able to set the root selector correctly" do
        pm("/a", :read_root).is_a?(RootSelector).should be(true)
      end
    end

=begin
    it "should be able to do a simple child selector" do
      yaml = yo({'a' => 'b'})
      finding(yaml, "/a").should eql('b')
    end
=end
  end
end
