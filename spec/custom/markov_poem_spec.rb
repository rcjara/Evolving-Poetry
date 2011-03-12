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
        @p.display.should == %{<span class="new-text"> Take this kiss</span> upon the brow!}
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
      @text_with_deleted_tags = "BEGINDELETED take ENDDELETED this BREAK kiss upon the brow !"
    end

    describe "without stripping tags" do
      before(:each) do
        @p = MarkovPoem.from_prog_text(@text_with_deleted_tags, @lang)
      end

      it "should display properly" do
        @p.display.should == %{<span class="deleted-text"> Take this</span><br />\nKiss upon the brow!}
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

  describe "sexual reproduction" do
    before(:each) do
      @p1 = @lang.gen_poem(6)
      @p2 = @lang.gen_poem(4)
      @new_poem = @p1.sexually_reproduce_with(@p2, @lang)
    end

    describe "@p1.half_lines" do
      it "should have 3 lines" do
        @p1.half_lines.length.should == 3
      end
    end
    
    describe "@p2.half_lines" do
      it "should have 2 lines" do
        @p2.half_lines.length.should == 2
      end
    end

    it "should have 5 lines" do
      @new_poem.length.should == 5
    end
    
    it "should have 3 lines from p1 in its programmatic text" do
      @new_poem.to_prog_text.scan(/FROMFIRSTPARENT/).length.should == 3
    end
    
    it "should have 3 lines from p1 in its display text" do
      @new_poem.display.scan(/\<span class\=\"from-first-parent\"\>/).length.should == 3
    end
    
    it "should have 2 lines from p2 in its programmatic text" do
      @new_poem.to_prog_text.scan(/FROMSECONDPARENT/).length.should == 2
    end
    
    it "should have 2 lines from p2 in its display text" do
      @new_poem.display.scan(/\<span class\=\"from-second-parent\"\>/).length.should == 2
    end
    
  end
  

  describe "multiline stripping" do
    before(:each) do
      @text_to_strip = "take BEGINDELETED this kiss ENDDELETED upon BREAK BEGINDELETED the brow ENDDELETED BREAK BEGINNEWTEXT and ENDSPAN raven !"
      @p = MarkovPoem.from_prog_text(@text_to_strip, @lang, :strip => true)
    end

    it "should have the right programmatic text" do
      @p.to_prog_text.should == "take BREAK and raven !"
    end

    it "should display properly" do
      @p.display.should == "Take<br />\nAnd raven!"
    end
    
  end

  describe "a five line poem" do
    before(:each) do
      @p = @lang.gen_poem(5)
    end

    it "should not contain any beginnewtext tags" do
      @p.display.should_not =~ /\<span class\="new-text"\>/
    end

    it "should have 5 lines" do
      @p.length.should == 5
    end
    
    
    describe "now add the line" do
      before(:each) do
        @p.add_line!(@lang)
      end

      it "should include a new text tag" do
        @p.display.should =~ /\<span class\="new-text"\>/
      end

      it "should have 6 lines" do
        @p.length.should == 6
      end
    end

    describe "on deleting a line" do
      before(:each) do
        @p.delete_line!
      end
      
      it "should still have 5 lines" do
        @p.length.should == 5
      end

      it "should have 4 undeleted lines" do
        @p.undeleted_lines.should == 4
      end
      

      it "should have some deleted text" do
        @p.to_prog_text.should =~ /BEGINDELETED.*?ENDDELETED/
      end
      
      describe "and then stripping out tags" do
        before(:each) do
          @p = MarkovPoem.from_prog_text(@p.to_prog_text, @lang, :strip => true)
        end
        
        it "should still have 4 lines" do
          @p.length.should == 4
        end

        it "should not deleted text anymore" do
          @p.to_prog_text.should_not =~ /BEGINDELETED.*?ENDDELETED/
        end

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

