describe SpaceOut do
  describe "stand alone examples" do
    it "should handle 3, 5" do
      SpaceOut::space(1.upto(3).to_a, 5).should == [1, nil, 2, nil, 3]
    end

    it "should handle 3, 7" do
      SpaceOut::space(1.upto(3).to_a, 7).should == [1, nil, nil, 2, nil, nil, 3]
    end
    
    it "should handle 3, 6" do
      SpaceOut::space(1.upto(3).to_a, 6).should == [1, nil, 2, nil, 3, nil]
    end

    it "should handle 4, 6" do
      SpaceOut::space(1.upto(4).to_a, 6).should == [1, nil, 2, 3, nil, 4]
    end
  end
end
