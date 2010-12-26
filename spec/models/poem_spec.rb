require 'spec_helper'

describe Poem do
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
  
  
  describe "after voting against a poem 4 times" do
    before(:each) do
      4.times{@poem.vote_against!}
    end
    
    it "should have 4 votes against it" do
      @poem.votes_against.should == 4
    end
    
    it "should be dead" do
      @poem.alive?.should be_false
    end
    
  end

  describe "after creating an identical a child" do
    before(:each) do
      @poem2 = @poem.create_identical_child
      @poem2.save
      @poem.reload
    end
    
    it "the child should have the first poem as its parent" do
      @poem2.parent.should == @poem
    end

    it "the child should have the same family as the first poem" do
      @poem2.family.should == @poem.family
    end
    
    it "the child should have the same language as the first poem" do
      @poem2.language.should == @poem.language
    end
    
    it "the parent should have the second poem as its child" do
      @poem.children.should include @poem2
    end
    
  end
  

  
end

