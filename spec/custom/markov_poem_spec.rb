describe MarkovPoem do
  before(:all) do
    @lang = poe_language
  end

  describe "new text tags" do
    before(:each) do
      @text_with_span_tags = "BEGINNEWTEXT take this ENDSPAN kiss upon the brow !"
    end
    
    describe "without stripping tags" do
      before(:each) do
        @p = MarkovPoem.from_prog_text(@text_with_span_tags, @lang)
      end

      it "should display properly" do
        @p.display.should == %{<span class="new_text"> Take this kiss</span> upon the brow!}
      end

      it "should have the right programmatic text" do
        @p.to_prog_text.should == @text_with_span_tags
      end
      
    end

    describe "with stripping out tags" do
      before(:each) do
        @p = MarkovPoem.from_prog_text(@text_with_span_tags, @lang, {:strip => true})
      end

      it "should display properly" do
        @p.display.should == %{Take this kiss upon the brow!}
      end

      it "should have the right programmatic text" do
        @p.to_prog_text.should == "take this kiss upon the brow !"
      end
      
    end
  end

  describe "deleted text tags" do
    before(:each) do
      @text_with_deleted_tags = "BEGINDELETED take ENDSPAN this BREAK kiss upon the brow !"
    end

    describe "without stripping tags" do
      before(:each) do
        @p = MarkovPoem.from_prog_text(@text_with_deleted_tags, @lang)
      end

      it "should display properly" do
        @p.display.should == %{<span class="deleted_text"> Take this</span><br />\nKiss upon the brow!}
      end

      it "should have the right programmatic text" do
        @p.to_prog_text.should == @text_with_deleted_tags
      end
      
    end

    describe "with stripping out tags" do
      before(:each) do
        @p = MarkovPoem.from_prog_text(@text_with_deleted_tags, @lang, :strip => true)
      end

      it "should display properly" do
        @p.display.should == %{Kiss upon the brow!}
      end

      it "should have the right programmatic text" do
        @p.to_prog_text.should == "kiss upon the brow !"
      end
      
    end
  end

  describe "multiline stripping" do
    before(:each) do
      @text_to_strip = "take BEGINDELETED this kiss ENDSPAN upon BREAK BEGINDELETED the brow ENDSPAN BREAK BEGINNEWTEXT and ENDSPAN raven !"
      @p = MarkovPoem.from_prog_text(@text_to_strip, @lang, :strip => true)
    end

    it "should have the right programmatic text" do
      @p.to_prog_text.should == "take BREAK and raven !"
    end

    it "should display properly" do
      @p.display.should == "Take<br />\nAnd raven!"
    end
    
  end

  describe "adding a line" do
    before(:each) do
      @p = @lang.gen_poem(5)
    end

    it "should not contain any beginnewtext tags" do
      @p.display.should_not =~ /\<span class\="new_text"\>/
    end

    it "should have 5 lines" do
      @p.length.should == 5
    end
    
    
    describe "now add the line" do
      before(:each) do
        @p.add_line!(@lang)
      end

      it "should include a new text tag" do
        @p.display.should =~ /\<span class\="new_text"\>/
      end

      it "should have 6 lines" do
        @p.length.should == 6
      end
    end
  end

  describe "altering the tail of a line" do
    before(:each) do
      @p = @lang.gen_poem 1
      @pre_display = @p.display 
      @first_word = @p.to_prog_text.split(/\s/).first
      @p.alter_a_tail!(@lang)
    end
    
    it "should not look like it used to" do
      @p.display.should_not == @pre_display
    end

    it "should still have the first word in common" do
      @p.to_prog_text.split(/\s/).first.should == @first_word
    end

    it "should still have a length of one" do
      @p.length.should == 1
    end
    
  end
  
  describe "altering the front of a line" do
    before(:each) do
      @p = @lang.gen_poem 1
      @pre_display = @p.display 
      @last_word = @p.to_prog_text.split(/\s/).last
      @p.alter_a_front!(@lang)
    end
    
    it "should not look like it used to" do
      @p.display.should_not == @pre_display
    end

    it "should still have the last word in common" do
      @p.to_prog_text.split(/\s/).last.should == @last_word
    end

    it "should still have a length of one" do
      @p.length.should == 1
    end
    
  end
  
end

