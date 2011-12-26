require_relative "custom_helper"
include CustomHelper

describe FamilyTree do

  describe "basic family tree" do
    before(:each) do
      @p1 = PoemStub.new
      @p2 = PoemStub.new @p1
      @p3 = PoemStub.new @p1
      @p4 = PoemStub.new @p1
      @all_poems = [@p1, @p2, @p3, @p4]
    end

    let :tree do
      FamilyTree.new(@all_poems)
    end

    it "should be able to find the right immediate children" do
      tree.children_hash[@p1].should == [@p2, @p3, @p4]
      tree.children_hash[@p2].should == []
    end


    it "should have the right family tree structure" do
      tree.structure(lines: false).should == [[@p1, nil, nil],
                                              [@p2, @p3, @p4]]
    end

    it "should have the right family tree structure with lines" do
      tree.structure.should == [[@p1, nil, nil],
                                ['[', 'T', ']'],
                                [@p2, @p3, @p4]]
    end

    describe "adding a third generation" do
      before(:each) do
        @p5 = PoemStub.new @p3
        @p6 = PoemStub.new @p3
        @p7 = PoemStub.new @p4
        @all_poems += [@p5, @p6, @p7]
      end

      it "should have the right family tree structure with lines" do
        tree.structure.should == [[@p1, nil, nil, nil],
                                 ['[', 'T', '-', ']'],
                                 [@p2, @p3, nil, @p4],
                                 [nil, '[', ']', '|'],
                                 [nil, @p5, @p6, @p7]]
      end

      describe "adding a fourth generation" do
        before(:each) do
          @p8  = PoemStub.new @p5
          @p9  = PoemStub.new @p5
          @p10 = PoemStub.new @p7
          @all_poems += [@p8, @p9, @p10]
        end

        it "should have the right family tree structure with lines" do
          tree.structure.should == [[@p1, nil, nil, nil],
                                    ['[', 'T', '-', ']'],
                                    [@p2, @p3, nil, @p4],
                                    [nil, '[', ']', '|'],
                                    [nil, @p5, @p6, @p7],
                                    [nil, '[', ']', '|'],
                                    [nil, @p8, @p9, @p10]]
        end

        it "should display the right family tree structure (with lines)" do
          tree.display.should == <<EOS
p . . .
[ T - ]
p p . p
. [ ] |
. p p p
. [ ] |
. p p p
EOS
        end
      end

      describe "Alt Fourth Generation" do
        before(:each) do
          @p8  = PoemStub.new @p4
          @p9  = PoemStub.new @p5
          @p10 = PoemStub.new @p5
          @p11 = PoemStub.new @p5
          @p12 = PoemStub.new @p8
          @all_poems += [@p8, @p9, @p10, @p11, @p12]
        end

        it "should have the right family tree structure with lines" do
          tree.structure.should == [[@p1, nil, nil,  nil,  nil],
                                    ['[', 'T', '-',  ']',  nil],
                                    [@p2, @p3, nil,  @p4,  nil],
                                    [nil, '[', ']',  '[',  ']'],
                                    [nil, @p5, @p6,  @p7,  @p8],
                                    [nil, '[', 'T',  ']',  '|'],
                                    [nil, @p9, @p10, @p11, @p12]]
        end
      end

    end
  end

end

