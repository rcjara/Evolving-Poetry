require_relative "../support/custom_helper"

include CustomHelper

describe ChildrenWithFathers do
  let :children do
    ChildrenWithFathers.new(@all_poems)
  end

  describe "basic scenario" do
    before(:each) do
      @parent = PoemStub.new

      @p1 = PoemStub.new @parent
      @p2 = PoemStub.new @parent
      @p3 = PoemStub.new @parent, 1
      @p4 = PoemStub.new @parent, 1
      @p5 = PoemStub.new @parent, 2
      @p6 = PoemStub.new @parent, 3
      @p7 = PoemStub.new @parent, 3

      @all_poems = [@p1, @p2, @p3, @p4, @p5, @p6, @p7]
    end

    describe "#bastards" do
      it "should only have poems without fathers" do
        children.bastards.should == [@p1, @p2]
      end

    end

    describe "#by_father" do
      it "should have the children arranged by father" do
        children.by_father.should ==
          {
            1 => [@p3, @p4],
            2 => [@p5],
            3 => [@p6, @p7]
          }
      end

    end

  end
end
