describe MarkovPoem do
  before(:all) do
    @lang = poe_language
  end

  describe "span tags" do
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
  
end

