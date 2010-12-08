describe ApplicationHelper do
  describe "proper_list" do
    it "should handle a list of size 1" do
      proper_list(%w[this]).should == "this"
    end

    it "should handle a list of size 2" do
      proper_list(%w[this that]).should == "this and that"
    end

    it "should handle a list of size 3" do
      proper_list(%w[this that other]).should == "this, that and other"
    end
    
    it "should handle a list of size 5" do
      proper_list(%w[planes trains bikes cars skateboards]).should == "planes, trains, bikes, cars and skateboards"
    end
  end
  
end

