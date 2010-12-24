require 'spec_helper'

describe Language do
  before(:each) do
    @l = Language.create!(:name => "test name")
  end
  
  describe "adding and removing authors" do
    before(:each) do
      @a = author_create
      work_create @a
      @l.add_author!(@a)
    end

    it "should have added an author" do
      @l.authors.length.should == 1
    end

    it "should show that it has the right author" do
      @l.has_author?(@a).should be_true
    end
    
    
    it "should be able to remove an author" do
      @l.remove_author!(@a)
      @l.reload
      @l.authors.length.should == 0
    end

    it "should have 0 votes" do
      @l.total_votes.should == 0
    end

    it "should be able to accept a vote" do
      @l.add_vote!
      @l.reload
      @l.total_votes.should == 1
    end
    
    

    describe "generating a poem" do
      before(:each) do
        @l.gen_poem!
        @l.reload
      end
      
      it "should have a poem" do
        @l.poems.length.should == 1
      end

      it "should have a poem with programmatic text" do
        @l.poems.first.programmatic_text.length.should > 0
      end
      
      it "should have a poem with full text" do
        @l.poems.first.full_text.length.should > 0
      end
      
      
    end

    describe "generating a couple of poems" do
      before(:each) do
        3.times { @l.gen_poem! }
        @l.reload
      end

      it "should have 3 poems" do
        @l.poems.length.should == 3
      end

      it "they should all have the right familes" do
        @l.poems.each_with_index do |poem, i|
          poem.family.should == (i + 1)
        end
      end
      
      
      
    end
    
    
    
    
  end
  
end
