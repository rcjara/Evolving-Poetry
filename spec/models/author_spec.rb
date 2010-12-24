require 'spec_helper'

describe Author do
  before(:each) do
    @author = author_create
  end

  it "should not have any works" do
    @author.works.should be_empty
  end
  

  describe "after adding a work" do
    before(:each) do
      work_create(@author)
      @author.reload
    end
    
    it "should" do
      @author.works.length.should == 1
    end
    
  end
  
  
end
