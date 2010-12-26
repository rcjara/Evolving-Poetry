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
end

