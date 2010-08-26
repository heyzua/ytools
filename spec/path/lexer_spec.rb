require 'ytools/path/lexer'

module YTools::YPath

  module PathHelper
    def lexer(path)
      Lexer.new(path)
    end
    
    def check_token(path, type, count=nil)
      count ||= 1
      lex = lexer(path)

      if count == 0
        return lex.next # '/'
      end

      tok = nil
      0.upto(count) do
        tok = lex.next
      end
      
      tok.type.should eql(type)
      tok
    end

    def check_path(path, part, count=nil)
      tok = check_token(path, :path_part, count)
      tok.path.should eql(part)
    end
  end

  describe "Token struct" do
    it "should have a 'value' method that returns the underlying implementation string/number" do
      Token.new("/42", 1, 2, :number).value.should eql(42)
    end
  end

  describe "Lexer" do
    include PathHelper

    it "should fail when the path doesn't start with a '/'" do
      attempting { lexer('no path') }.should raise_error(YTools::PathError, /start with a '\/'/)
    end

    it "should be able to parse a simple path separator" do
      tok = check_token('/', :path_separator, 0)
      tok.offset.should eql(0)
      tok.length.should eql(1)
    end

    it "should be able to parse an '@' character" do
      check_token('/@', :at)
    end

    it "should be able to parse a '[' character" do
      check_token('/[', :lbrace)
    end

    it "should be able to parse a ']' character" do
      check_token('/]', :rbrace)
    end

    it "should be able to parse a string in single quotes correctly" do
      check_token("/'this is a string'", :string)
    end

    it "should fail when a string is not closed" do
      attempting_to { check_token("/'this", :string) }.should raise_error(YTools::PathError, /closed correctly/)
    end

    it "should correctly determine the length of the string" do
      tok = check_token("/'this'", :string)
      tok.length.should eql(4)
    end

    it "should correctly parse a single quoted string" do
      check_token('/"this"', :string)
    end

    it "should correctly parse a number" do
      check_token('/42', :number)
    end

    it "should know the position of the number" do
      tok = check_token('/42', :number)
      tok.length.should eql(2)
      tok.offset.should eql(1)
    end

    it "should always return nil when examining past the end of the line." do
      lex = lexer('/')
      lex.next.should_not be(nil)
      lex.next.should be(nil)
    end

    it "should return nil on indexing past the end of the path." do
      lex = lexer('/this is a path')
      lex[50].should be(nil)
    end

    it "should be able to find a basic path part" do
      check_path('/path_token', 'path_token')
    end

    it "should be able to find a path using bars" do
      check_path('/|complex/path/parts|', 'complex/path/parts')
    end

    it "should fail when a barred path isn't closed" do
      attempting_to { check_path('/|noend bar', nil) }.should raise_error(YTools::PathError, /bar/)
    end

    it "should handle the basic backslash escape of special characters" do
      check_path("/bath\\@here", 'bath@here')
    end

    it "should fail when a backslash character is unescaped" do
      attempting_to { check_path("/back\\slash", nil) }.should raise_error(YTools::PathError, /backslash/)
    end

    it "should fail when the backslash character is last" do
      attempting_to { check_path("/back\\", nil) }.should raise_error(YTools::PathError, /Last/)
    end

    it "should succeed to parse multiple paths according to slashes" do
      check_path('/this/goes', 'goes', 3)
    end
  end
end
