describe FamilyTreeCompressor do
  before(:each) do
    @p1 = Poem.new
    @p2 = Poem.new
    @p3 = Poem.new
    @p4 = Poem.new
  end
  
  describe "given an uncompressable tree" do
    before(:each) do
      @tree = 
        [[@p1, nil, nil],
         ['[', 'T', ']'],
         [@p2, @p3, @p4]]
      @ans = FamilyTreeCompressor.compress(@tree)
      @string = <<EOS
p . .
[ T ]
p p p
EOS

    end

    it "should have no blank regions" do
      FamilyTreeCompressor.identify_blank_regions(@tree).should be_nil
    end
    
    
    it "should return the same tree" do
      @ans.should == @tree
    end

    it "should be able to show the original tree as a string" do
      FamilyTreeCompressor.string(@tree).should == @string
    end

    it "should be able to show the answer as a string" do
      FamilyTreeCompressor.string(@ans).should == @string
    end
    
  end

  describe "given a 3-gen simple compressable tree" do
    before(:each) do
      @tree = 
        [[@p1, nil, nil],
         ['[', '-', ']'],
         [@p2, nil, @p3],
         ['[', ']', nil],
         [@p4, @p4, nil]]
      @string = <<EOS
p . .
[ - ]
p . p
[ ] .
p p .
EOS
      @ans = FamilyTreeCompressor.compress(@tree)
    end

    it "should be able to identify the blank region" do
      FamilyTreeCompressor.identify_blank_regions(@tree).should ==
       [[1, 1]]
    end

    it "should be able to get the right edges for the blank region" do
      FamilyTreeCompressor.edges_for_index(@tree, 1).should == [[1, 6]]
    end
    
    it "should be able to slide properly" do
      FamilyTreeCompressor.slide(@tree, [1, 1], [[1, 6]], 1).should ==
        [[@p1, nil],
         ['[', ']'],
         [@p2, @p3],
         ['[', ']'],
         [@p4, @p4]]
    end
    
    it "should be able to slide (as string)" do
      FamilyTreeCompressor.string(FamilyTreeCompressor.slide(@tree, [1, 1], [[1, 6]], 1)).should == <<EOS
p .
[ ]
p p
[ ]
p p
EOS
    end
    
    
    it "should return a compressed version of the tree" do
      @ans.should == 
        [[@p1, nil],
         ['[', ']'],
         [@p2, @p3],
         ['[', ']'],
         [@p4, @p4]]
    end

    it "should be able to return the answer as a string" do
      FamilyTreeCompressor.string(@ans).should == <<EOS
p .
[ ]
p p
[ ]
p p
EOS
    end
    

    it "should be able to display the tree as a string" do
      FamilyTreeCompressor.string(@tree).should == @string
    end
    
  end
  
  describe "a tree with many blank regions" do
    before(:each) do
      @tree = 
        [[@p1, nil, nil, nil, nil, nil, nil, nil],
         ['[', '-', '-', 'T', '-', 'T', '-', ']'],
         [@p2, nil, nil, @p2, nil, @p2, nil, @p2],
         ['[', 'T', ']', '[', ']', '[', ']', nil],
         [@p3, @p3, @p3, @p3, @p3, @p3, @p3, nil]]
      @string = <<EOS
p . . . . . . .
[ - - T - T - ]
p . . p . p . p
[ T ] [ ] [ ] .
p p p p p p p .
EOS
      @ans = FamilyTreeCompressor.compress(@tree)
    end
    
    it "should be able to display the tree as a string" do
      FamilyTreeCompressor.string(@tree).should == @string
    end

    it "should be able to identify the blank regions" do
      FamilyTreeCompressor.identify_blank_regions(@tree).should == 
        [[1, 2], [4, 4], [6, 6]]
    end

    it "should get the right answer" do
      FamilyTreeCompressor.string(@ans).should == <<EOS
p . . . . . .
[ - - T - T ]
p . . p . p p
[ T ] [ ] [ ]
p p p p p p p
EOS
    end
    
    it "should be able to get the right edges for index 2" do
      FamilyTreeCompressor.edges_for_index(@tree, 2).should == 
        [[2, 3]]
    end

    it "should be able to get the right edges for index 4" do
      FamilyTreeCompressor.edges_for_index(@tree, 4).should == 
        [[4, 5]]
    end

    it "should be able to get the right edges for index 5" do
      FamilyTreeCompressor.edges_for_index(@tree, 6).should == 
        [[6, 16]]
    end
    
  end
  
  describe "a family tree with a huge blank region" do
    before(:each) do
      @tree = [
        [@p1, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
        ['[', '-', '-', '-', '-', 'T', 'T', 'T', ']', nil, nil],
        [@p2, nil, nil, nil, nil, @p2, @p2, @p2, @p2, nil, nil],
        ['[', '-', '-', '-', ']', nil, nil, nil, '[', '-', ']'],
        [@p3, @p3, @p3, @p3, @p3, nil, nil, nil, @p4, @p4, @p4]]
      @ans = FamilyTreeCompressor.compress(@tree)
    end
    
    it "should be able to display properly as a string" do
      FamilyTreeCompressor.string(@tree).should == <<EOS
p . . . . . . . . . .
[ - - - - T T T ] . .
p . . . . p p p p . .
[ - - - ] . . . [ - ]
p p p p p . . . p p p
EOS
    end

    it "should be able to display the right answer" do
      FamilyTreeCompressor.string(@ans).should == <<EOS
p . . . . . . .
[ - T T T ] . .
p . p p p p . .
[ - - - ] [ - ]
p p p p p p p p
EOS
    end

    it "should have the right answer" do
      @ans.should == [
        [@p1, nil, nil, nil, nil, nil, nil, nil],
        ['[', '-', 'T', 'T', 'T', ']', nil, nil],
        [@p2, nil, @p2, @p2, @p2, @p2, nil, nil],
        ['[', '-', '-', '-', ']', '[', '-', ']'],
        [@p3, @p3, @p3, @p3, @p3, @p4, @p4, @p4]]
    end
    
    describe "after adding another lines" do
      before(:each) do
        @tree = [
          [@p1, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
          ['[', '-', '-', '-', '-', '-', 'T', 'T', 'T', ']', nil, nil],
          [@p2, nil, nil, nil, nil, nil, @p2, @p2, @p2, @p2, nil, nil],
          ['[', '-', '-', '-', ']', nil, nil, nil, nil, '[', '-', ']'],
          [@p3, @p3, @p3, @p3, @p3, nil, nil, nil, nil, @p4, @p4, @p4],
          [nil, nil, nil, nil, '[', ']', nil, nil, nil, '|', nil, nil],
          [nil, nil, nil, nil, @p1, @p1, nil, nil, nil, @p1, nil, nil]]
        @ans = FamilyTreeCompressor.compress(@tree)
      end
      
      it "should be able to display properly as a string" do
        FamilyTreeCompressor.string(@tree).should == <<EOS
p . . . . . . . . . . .
[ - - - - - T T T ] . .
p . . . . . p p p p . .
[ - - - ] . . . . [ - ]
p p p p p . . . . p p p
. . . . [ ] . . . | . .
. . . . p p . . . p . .
EOS
      end

      it "should have the right blank regions" do
        FamilyTreeCompressor.identify_blank_regions(@tree).should == 
          [[1, 5], [10, 11]]
      end

      it "should have the right edges for the first region" do
        FamilyTreeCompressor.edges_for_index(@tree, 5).should ==
          [[4, 9], [5, 9]]
      end
      
      

      it "should be able to display the right answer" do
        FamilyTreeCompressor.string(@ans).should == <<EOS
p . . . . . . . .
[ - - T T T ] . .
p . . p p p p . .
[ - - - ] . [ - ]
p p p p p . p p p
. . . . [ ] | . .
. . . . p p p . .
EOS
      end

      it "should have the right answer" do
        @ans.should == [
          [@p1, nil, nil, nil, nil, nil, nil, nil, nil],
          ['[', '-', '-', 'T', 'T', 'T', ']', nil, nil],
          [@p2, nil, nil, @p2, @p2, @p2, @p2, nil, nil],
          ['[', '-', '-', '-', ']', nil, '[', '-', ']'],
          [@p3, @p3, @p3, @p3, @p3, nil, @p4, @p4, @p4],
          [nil, nil, nil, nil, '[', ']', '|', nil, nil],
          [nil, nil, nil, nil, @p1, @p1, @p1, nil, nil]]
      end
      
    end
  end

  describe "a tree where there are more 3rd generation poems than 2nd" do
    before(:each) do
      @tree = [
          [@p1, nil, nil, nil, nil, nil, nil],
          ['[', '-', '-', '-', '-', 'T', ']'],
          [@p2, nil, nil, nil, nil, @p2, @p2],
          ['[', 'T', 'T', 'T', ']', nil, nil],
          [@p3, @p3, @p3, @p3, @p3, nil, nil]]
      @ans = FamilyTreeCompressor.compress(@tree)
    end
    
    it "should display properly as a string" do
      FamilyTreeCompressor.string(@tree).should == <<EOS
p . . . . . .
[ - - - - T ]
p . . . . p p
[ T T T ] . .
p p p p p . .
EOS
    end
    
    it "should be able to display the right answer" do
      FamilyTreeCompressor.string(@ans).should == <<EOS
p . . . .
[ T ] . .
p p p . .
[ T T T ]
p p p p p
EOS
    end
    
    
  end
  
end

