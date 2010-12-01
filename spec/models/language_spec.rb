require 'spec_helper'

describe Language do
  before(:each) do
    @l = Language.create!(:name => "test name")
  end
  
  describe "adding and removing authors" do
    before(:each) do
      @a = Author.create!(:full_name => "Edgar Allan Poe", :first_name => "Edgar", :last_name => "Poe")
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
    
    
  end
  
end
