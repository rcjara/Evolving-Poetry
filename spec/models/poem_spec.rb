require 'spec_helper'

describe Poem do
  shared_examples_for "any child of a poem" do
    it "should have the first poem as its parent" do
      @new_poem.parent.should == @poem
    end
    
    it "should have no votes_for/against" do
      @new_poem.votes_for.should == 0
      @new_poem.votes_against.should == 0
    end
    
    it "should have the same language as its parent" do
      @new_poem.language.should == @poem.language
    end
    
    it "the parent should have the second poem as its child" do
      @poem.children.should include @new_poem
    end
    
    it "should have the same family as its parent" do
      @new_poem.family.should == @poem.family
    end
  end

  before(:each) do
    @author, @work, @language = author_work_language_combo
    @poem = @language.gen_poem!
  end

  it "should have a family" do
    @poem.family.should_not be_nil
    @poem.family.should_not == 0
  end

  it "should not have a second family" do
    @poem.second_family.should be_nil
  end
  
  it "should not have a parent" do
    @poem.parent.should be_nil
  end

  it "should not have a second parent" do
    @poem.second_parent.should be_nil
  end
  
  it "should have full text with multiple lines" do
    @poem.full_text.split("<br />").length.should > 1
  end

  it "should have no votes for" do
    @poem.votes_for.should == 0
  end

  it "should have a programmatic text" do
    @poem.programmatic_text.split(/\s/).length.should > 1
  end

  it "shouldn't have any children" do
    @poem.children.should be_empty
  end
  

  describe "programmatic text stuff" do
    before(:each) do
      @markov_form = MarkovPoem.from_prog_text(@poem.programmatic_text, @poem.language.markov)
    end
    
    it "should be able to recreate the display text from the markov form" do
      @markov_form.display.should == @poem.full_text 
    end

    it "should have the same programaatic text as the poem" do
      @markov_form.to_prog_text.should == @poem.programmatic_text
    end
    
  end
  
  
  describe "after voting for a poem" do
    before(:each) do
      @poem.vote_for!
      @poem.reload
      @language.reload
    end
    
    it "should have a vote" do
      @poem.votes_for.should == 1
    end
    
    it "the language should have a vote" do
      @language.total_votes.should == 1
    end

    it "should have a score of one" do
      @poem.score.should == 1
    end
    
    
  end

  describe "after being voted against once" do
    before(:each) do
      @poem.vote_against!
    end

    it "should have one vote against it" do
      @poem.votes_against.should == 1
    end

    it "should still be alive" do
      @poem.alive?.should be_true
    end
    
    
  end

  describe "after being voted for then against" do
    before(:each) do
      @poem.vote_for!
      @poem.reload
      @poem.vote_against!
      @poem.reload
    end
    
    it "should have a score of zero" do
      @poem.score.should == 0
    end
    
  end

  describe "after voting for it enough to reproduce" do
    before(:each) do
      5.times { @language.gen_poem! }
      @language.reload

      @num_poems = @language.poems.length
      (1 + Constants::BEAR_CHILD_CUTOFF).times{ @poem.vote_for! }
      @poem.reload
      @language.reload
    end
    
    it "should have a score of zero" do
      @poem.score == 0
    end
    
    it "should have a child" do
      @poem.children.length.should == 1
    end
    
    describe "the language" do
      it "should have one more poem than it did before" do
        @language.poems.length.should == @num_poems + 1
      end
      
    end
    
  end
  
  describe "after voting against a poem 4 times" do
    before(:each) do
      @num_poems = @poem.language.alive_poems.length
      4.times{@poem.vote_against!}
      @poem.reload
      @poem.language.reload
    end
    
    it "should have 4 votes against it" do
      @poem.votes_against.should == 4
    end
    
    it "should be dead" do
      @poem.alive?.should be_false
    end

    describe "the poem's language" do
      it "should not have the same number of poems as before" do
        @poem.language.alive_poems.length.should_not == @num_poems
      end
      
      it "should no longer include the original poem in its alive poems" do
        @poem.language.alive_poems.should_not include @poem
      end
      
    end
    
    
  end

  describe "after creating an identical a child" do
    before(:each) do
      @new_poem = @poem.create_identical_child
      @new_poem.save
      @poem.reload
    end
    
    it_should_behave_like "any child of a poem"
  end
  
  describe "after asexually reproducing" do
    before(:each) do
      @new_poem = @poem.asexually_reproduce!
      @new_poem.save
      @poem.reload
    end
    
    it "should have the new poem as a child" do
      @poem.children.should include(@new_poem)
    end

    describe "its child" do
      it_should_behave_like "any child of a poem"

      it "should have a different programmatic text than its parent" do
        @new_poem.programmatic_text.should_not == @poem.programmatic_text
      end

      it "should have a different full text than its parent" do
        @new_poem.full_text.should_not == @poem.full_text
      end
    end
  end

  describe "after sexually reproducing" do
    before(:each) do
      @poem2 = @language.gen_poem!
      @new_poem = @poem.sexually_reproduce_with!(@poem2)
      @new_poem.save
      @poem.reload
      @poem2.reload
    end
    
    describe "the first poem" do
      it "should have the new poem in its children" do
        @poem.children.should include @new_poem
      end
    end

    describe "the second poem" do
      it "should have the new poem in its second children" do
        @poem2.second_children.should include @new_poem
      end
    end
    
    
    describe "the new poem" do
      it_should_behave_like "any child of a poem"

      it "should have the second family of poem2" do
        @new_poem.second_family.should == @poem2.family
      end

      it "should have poem2 as a second parent" do
        @new_poem.second_parent.should == @poem2
      end
    end
  end
  
  describe "family trees" do
    before(:each) do
      @auth, @work, @lang = author_work_language_combo
    end
    
    describe "basic family tree" do
      before(:each) do
        @p1 = @lang.gen_poem!
        @p2 = @p1.asexually_reproduce!
        @p3 = @p1.asexually_reproduce!
        @p4 = @p1.asexually_reproduce!
        @full_family = [@p1, @p2, @p3, @p4]
        @other = @lang.gen_poem!
      end

      it "should be able to get it's children via magic" do
        @p1.get_tree_children(@p1.family_members).should == [@p2, @p3, @p4]
      end
      
      it "should have the right family tree structure" do
        @p1.fam_tree_struct.should == [[@p1, nil, nil],
                                       [@p2, @p3, @p4]]
      end

      it "should have the same structure regardless of the child" do
        @full_family.each_cons(2) do |lft_p, rgt_p|
          lft_p.fam_tree_struct.should == rgt_p.fam_tree_struct
        end
      end

      describe "adding a third generation" do
        before(:each) do
          @p5 = @p3.asexually_reproduce!
          @p6 = @p3.asexually_reproduce!
          @p7 = @p4.asexually_reproduce!
        end

        it "should have the right family tree structure with lines" do
          @p1.fam_tree_struct_with_lines.should == [[@p1, nil, nil, nil],
                                                    ['[', 'T', '-', ']'],
                                                    [@p2, @p3, nil, @p4],
                                                    [nil, '[', ']', '|'],
                                                    [nil, @p5, @p6, @p7]]
        end
        
        it "should have the right family tree structure" do
          @p1.fam_tree_struct.should == [[@p1, nil, nil, nil],
                                         [@p2, @p3, nil, @p4],
                                         [nil, @p5, @p6, @p7]]
        end
        
        describe "adding a fourth generation" do
          before(:each) do
            @p8 = @p5.asexually_reproduce!
            @p9 = @p5.asexually_reproduce!
            @p10 = @p7.asexually_reproduce!
          end
          
          it "should have the right family tree structure with lines" do
            @p1.fam_tree_struct_with_lines.should == [[@p1, nil, nil, nil],
                                                      ['[', 'T', '-', ']'],
                                                      [@p2, @p3, nil, @p4],
                                                      [nil, '[', ']', '|'],
                                                      [nil, @p5, @p6, @p7],
                                                      [nil, '[', ']', '|'],
                                                      [nil, @p8, @p9, @p10]]
          end

          it "should have the right family tree structure" do
            @p1.fam_tree_struct.should == [[@p1, nil, nil, nil],
                                           [@p2, @p3, nil, @p4],
                                           [nil, @p5, @p6, @p7],
                                           [nil, @p8, @p9, @p10]]
          end
        end
        
      end
      
      
    end
    
  end
  
end

