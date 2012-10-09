require_relative "../custom_helper"
include CustomHelper

describe FamilyTree::Tree do

  describe "basic family tree" do
    before(:each) do
      @p1 = PoemStub.new
      @p2 = PoemStub.new @p1
      @p3 = PoemStub.new @p1
      @p4 = PoemStub.new @p1
      @all_poems = [@p1, @p2, @p3, @p4]
    end

    subject { FamilyTree::Tree.new(@all_poems) }

    its(:structure_without_lines) { should == [[@p1, nil, nil],
                                               [@p2, @p3, @p4]] }

    its(:structure) { should == [[@p1, nil, nil],
                                 ['[', 'T', ']'],
                                 [@p2, @p3, @p4]] }

    describe "with a third generation" do
      before(:each) do
        @p5 = PoemStub.new @p3
        @p6 = PoemStub.new @p3
        @p7 = PoemStub.new @p4
        @all_poems += [@p5, @p6, @p7]
      end

      its(:structure) { should == [[@p1, nil, nil, nil],
                                   ['[', 'T', '-', ']'],
                                   [@p2, @p3, nil, @p4],
                                   [nil, '[', ']', '|'],
                                   [nil, @p5, @p6, @p7]] }

      describe "with a fourth generation" do
        before(:each) do
          @p8  = PoemStub.new @p5
          @p9  = PoemStub.new @p5
          @p10 = PoemStub.new @p7
          @all_poems += [@p8, @p9, @p10]
        end

        its(:structure) { should == [[@p1, nil, nil, nil],
                                   ['[', 'T', '-', ']'],
                                   [@p2, @p3, nil, @p4],
                                   [nil, '[', ']', '|'],
                                   [nil, @p5, @p6, @p7],
                                   [nil, '[', ']', '|'],
                                   [nil, @p8, @p9, @p10]] }

        its(:display) { should == ["p . . .",
                                   "[ T - ]",
                                   "p p . p",
                                   ". [ ] |",
                                   ". p p p",
                                   ". [ ] |",
                                   ". p p p"].join("\n") }
      end

      describe "with an alternate fourth Generation" do
        before(:each) do
          @p8  = PoemStub.new @p4
          @p9  = PoemStub.new @p5
          @p10 = PoemStub.new @p5
          @p11 = PoemStub.new @p5
          @p12 = PoemStub.new @p8
          @all_poems += [@p8, @p9, @p10, @p11, @p12]
        end

        its(:structure) { should == [[@p1, nil, nil,  nil,  nil],
                                     ['[', 'T', '-',  ']',  nil],
                                     [@p2, @p3, nil,  @p4,  nil],
                                     [nil, '[', ']',  '[',  ']'],
                                     [nil, @p5, @p6,  @p7,  @p8],
                                     [nil, '[', 'T',  ']',  '|'],
                                     [nil, @p9, @p10, @p11, @p12]] }
      end

    end
  end
end

