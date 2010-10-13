require 'helpers'
require 'ytools/errors'
require 'ytools/path/lexer'
require 'ytools/path/parser'

module YTools::Path

  module PathParserHelper
    # Call private methods on the parser
    def pm(path, method=nil)
      method ||= :parse!
      parser = Parser.new(path)
      parser.send(method)
    end
  end

  describe "Path Parser" do
    include PathParserHelper

    describe "while doing index operations" do
      it "should fail when the number is nil" do
        attempting { pm("[", :index_selector) }.should raise_error(ParseError, /Missing number/)
      end

      it "should fail when the index isn't a number" do
        attempting { pm("[not_a_number]", :index_selector) }.should raise_error(ParseError, /Only numbers/)
      end

      it "should fail when the RBRACE isn't present" do
        attempting { pm("[1", :index_selector) }.should raise_error(ParseError, /Unclosed/)
      end

      it "should fail when the final index token isn't an RBRACE" do
        attempting { pm("[1/", :index_selector) }.should raise_error(ParseError, /Missing '\]'/)
      end

      it "should be able to pull an index selector" do
        pm("[23]", :index_selector).index.should eql(23)
      end
    end

    describe "while doing path node operations" do
      it "should be able to pull the node name" do
        pm("node", :path_node).child.should eql('node')
      end

      it "should be able to chain an index selector" do
        pm("node[1]", :path_node).subselector.index.should eql(1)
      end
    end

    describe "while doing child selector operations" do
      it "should be able to find descendent selectors" do
        pm("//descendant", :child_selector).should be_a(DescendantSelector)
      end

      it "should be able to find simple child selectors" do
        pm("/child", :child_selector).should be_a(ChildSelector)
      end

      it "should fail when the path doesn't begin with a '/'" do
        attempting_to { pm("child", :child_selector) }.should raise_error(ParseError, /Missing/)
      end

      it "should fail when the slash doesn't have anything after it" do
        attempting_to { pm("/", :child_selector) }.should raise_error(ParseError, /Unfinished/)
      end
    end

    describe "while doing root operations" do
      it "should be able to set the root selector correctly" do
        pm("/a", :root_selector).should be_a(RootSelector)
      end

      it "should not set the root selector ond descendant paths" do
        pm("//a", :root_selector).should be_a(DescendantSelector)
      end

      it "should not set the root selector on a basic path" do
        pm("a", :root_selector).should be_a(ChildSelector)
      end

      it "should correctly identify the child selector" do
        pm("/a[1]", :root_selector).subselector.child.should eql('a')
        pm("/a[1]", :root_selector).subselector.subselector.index.should eql(1)
      end
    end

    describe "while doing a full parse of a line" do
      it "should be able to pull out all of the selectors" do
        sel = pm("/a/b[2]//c")
        sel.should be_a(RootSelector)
        sel.subselector.should be_a(ChildSelector)
        sel.subselector.subselector.should be_a(ChildSelector)
        sel.subselector.subselector.subselector.should be_a(IndexSelector)
        sel.subselector.subselector.subselector.subselector.should be_a(DescendantSelector)
      end

      it "should return nil on an empty string" do
        pm("").should be(nil)
      end
    end
  end
end
