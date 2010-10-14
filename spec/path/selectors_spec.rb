require 'ytools/errors'
require 'ytools/yaml_object'
require 'ytools/path/selectors'

require 'helpers'

module YTools::Path

  describe "ChildSelector" do
    include YamlObjectHelper

    before :each do
      @obj = yo({'a' => {'b' => 'c', 'd' => 'e'}})
    end

    it "should be able to get the child node name" do
      cs = ChildSelector.new('a')
      cs.child.should eql('a')
    end

    it "should be able to select a single child element" do
      cs = ChildSelector.new('a')
      cs.select(@obj).b.should eql('c')
    end

    it "can chain child selectors together" do
      ca = ChildSelector.new('a')
      cb = ChildSelector.new('b')
      cc = ChildSelector.new('c')

      ca.chain(cb)
      ca.chain(cc)

      ca.subselector.should be(cb)
      cb.subselector.should be(cc)
    end

    it "should be able to chain selectors to find children" do
      ca = ChildSelector.new('a')
      cb = ChildSelector.new('b')
      ca.chain(cb)

      ca.select(@obj).should eql('c')
    end
  end

  describe "IndexSelector" do
    include YamlObjectHelper

    before :each do
      @obj = yo({'a' => {'b' => [1,2,3,4,5], 'c' => ['x', ['y', 'z']]}})
    end

    it "should be retrieve the index" do
      is = IndexSelector.new(2)
      is.index.should eql(2)
    end

    it "should retrieve a simple index" do
      is = IndexSelector.new(2)
      is.select(@obj.a.b).should eql(3)
    end

    it "should retrieve be able to chain to subselectors" do
      i1 = IndexSelector.new(1)
      i2 = IndexSelector.new(0)

      i1.chain(i2)
      i1.select(@obj.a.c).should eql('y')
    end
  end

  describe "RootSelector" do
    include YamlObjectHelper

    before :each do
      @obj = yo({'a' => {'b' => [1,2,3,4,5], 'c' => ['x', ['y', 'z']]}})
    end

    it "should retrieve the root path from any child" do
      rs = RootSelector.new
      rs.select(@obj.a).should be(@obj)
    end
  end

  describe "DescendantSelector" do
    include YamlObjectHelper

    it "should set the match property correctly" do
      DescendantSelector.new('b').match.should eql('b')
    end

    it "should pull out a single set of objects" do
      ms = DescendantSelector.new('b')
      o = yo({'a' => {'b' => {'b' => 'c'}}, 'b' => 'd'})

      ms.select(o).length.should eql(3)
    end

    it "should pull nodes from arrays as well" do
      ms = DescendantSelector.new('b')
      o = yo({'a' => {'b' => 'c'}, 'b' => [{'x' => 'y', 'b' => 'd'}, {'b' => 'q'}]})
      
      found = ms.select(o)
      found.length.should eql(4)
      found[0].should eql('c')
      found[1].should be_a(Array)
      found[2].should eql('d')
      found[3].should eql('q')
    end

    it "should be able to cull specific subselectors" do
      ms = DescendantSelector.new('c')
      ms.chain(IndexSelector.new(1))
      o = yo({'a' => {'b' => {'c' => [1, 2, 3]}}, 'c' => ['a', 'b', 'c']})

      found = ms.select(o)
      found.length.should eql(2)
      found[0].should eql(2)
      found[1].should eql('b')
    end

    it "should be able to pull out a list of subselectors" do
      sel = ChildSelector.new('path')
      sel.chain(DescendantSelector.new('subgroup'))
      o = yo({'path' => [{'subgroup' => 'a', 'c' => 'd'}, {'subgroup' => 'b', 'c' => 'd'}]})

      found = sel.select(o)
      found.length.should eql(2)
      found[0].should eql('a')
      found[1].should eql('b')
    end
  end
end
