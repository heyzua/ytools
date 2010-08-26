require 'ytools/errors'
require 'ytools/yaml_object'
require 'helpers'

module YTools

  module YamlObjectHelper
    def yo(hash)
      YamlObject.new(hash)
    end
  end

  describe "Yaml Object" do
    include YamlObjectHelper

    it "should retrieve keys that exist." do
      h = yo({'a' => 'b'})
      h['a'].should eql('b')
    end

    it "should create method definitions yor keys" do
      h = yo({'a' => 'b'})
      h.a.should eql('b')
    end

    it "should not spread the logic yor accessors across entire classes" do
      a = yo({'a' => 'b'})
      b = yo({'b' => 'c'})

      a.a.should eql('b')
      b.b.should eql('c')
      attempting { b.a }.should raise_error(YTools::PathError)
    end

    it "should be able to retrieve the its ypath." do
      h = yo({'a' => {'b' => 'c'}})
      h.ypath.should eql('/')
      h.a.ypath.should eql('/a')
    end

    it "should format the path of array children correctly." do
      h = yo({'a' => [{'b' => 'c'}, {'d' => {'e' => 'f'}}]})
      h.a[0].ypath.should eql('/a[0]')
      h.a[1].d.ypath.should eql('/a[1]/d')
    end

    it "should format funky child path names correctly in paths." do
      h = yo({'a' => {'b.c' => {'d' => 'e'}}})
      h.a.b_c.ypath.should eql("/a/@['b.c']")
    end

    it "should fail when a key is not present." do
      h = yo({'a' => 'b'})
      attempting { h['c'] }.should raise_error(YTools::PathError)
    end
  end
end
