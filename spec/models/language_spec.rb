require 'spec_helper'

describe Language do
  shared_examples_for "a language that hasn't had any poems reproduce" do
    it "should not have any poems generated sexually" do
      @l.poems_sexually_reproduced.should == 0
    end

    it "should not have any poems generated asexually" do
      @l.poems_asexually_reproduced.should == 0
    end
  end

  before(:each) do
    @l = Language.create!(:name => "test name")
  end

  describe "adding and removing authors" do
    before(:each) do
      @a = author_create
      work_create @a
      @l.add_author!(@a)
    end

    it_should_behave_like "a language that hasn't had any poems reproduce"

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

    it "should have no families" do
      @l.num_families.should == 0
    end




    describe "generating a poem" do
      before(:each) do
        @l.gen_poem!
        @l.reload
      end

      it_should_behave_like "a language that hasn't had any poems reproduce"

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

      it_should_behave_like "a language that hasn't had any poems reproduce"

      it "should have 3 poems" do
        @l.poems.length.should == 3
      end

      it "they should all have the right familes" do
        @l.poems.each_with_index do |poem, i|
          poem.family.should == (i + 1)
        end
      end

      describe "sexual reproduction" do
        before(:each) do
          @l.poems.sample.asexually_reproduce!
          2.times { @l.poems.sample.sexually_reproduce! }
          @l.reload
        end

        it "should have 1 asexually reproduced poems" do
          @l.poems_asexually_reproduced.should == 1
        end

        it "should have 2 sexually reproduced poems" do
          @l.poems_sexually_reproduced.should == 2
        end


      end

    end


    describe "after generating 20 poems" do
      before(:each) do
        20.times { @l.gen_poem! }
        @l.reload
        @l.poems.first.vote_against!
        @l.poems.last.vote_for!
      end

      it_should_behave_like "a language that hasn't had any poems reproduce"

      it "should have 20 poems" do
        @l.poems.length.should == 20
      end

      describe "the top 5 poems" do
        it "should have only 5 poems" do
          @l.poems.top_5.length.should == 5
        end

        it "should not include the first poem" do
          @l.poems.top_5.should_not include @l.poems.first
        end

        it "should include the last poem" do
          @l.poems.top_5.should include @l.poems.last
        end
      end

      describe "getting poems for voting" do
        before(:each) do
          @voters = @l.poems_for_voting
        end

        it "should return two items" do
          @voters.length.should == 2
        end

      end

    end
  end

end
