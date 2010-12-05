include MarkovHelper

describe MarkovLine do
  shared_examples_for "any line" do
    it "it's display length should equal it's num_chars" do
      @line.display.length.should == @line.num_chars
    end
    
  end

  before(:all) do
    @lang = poe_language
  end

  describe "basic adding of words" do
    before(:each) do
      @line = MarkovLine.new
      @lang.words[0..5].each do |word|
        @line.add_word( @lang.fetch_word(word) )
      end
    end

    it "should have a positive number of characters" do
      @line.num_chars.should be > 0
    end

    it_should_behave_like "any line"
    
    describe "after removing one word" do
      before(:each) do
        @old_length = @line.num_chars
        @line.remove_last_word
      end
      
      it_should_behave_like "any line"

      it "should have fewer characters" do
        @line.num_chars.should be < @old_length
      end
    end
    
    describe "after adding one word" do
      before(:each) do
        @old_length = @line.num_chars
        @line.add_word( @lang.fetch_word(@lang.words[6]) )
      end
      
      it_should_behave_like "any line"

      it "should have more characters" do
        @line.num_chars.should be > @old_length
      end
    end

    describe "to/from programmatic text" do
      before(:each) do
        @text = @line.to_prog_text
        @line2 = MarkovLine.from_prog_text(@text, @lang).first
      end

      it "text should contain only all upper or lower case words" do
        @text.split(" ").each do |w|
          (w.upcase == w || w.downcase == w).should be_true
        end
      end
      
      it "should have the same number of words" do
        @line.words.length.should == @line2.words.length
      end

      it "should have the same display sentence" do
        @line.display.should == @line2.display
      end
      
      describe "after altering the new line" do
        before(:each) do
          @line2.add_word( @lang.fetch_word(@lang.words[10]) )
        end
        
        it "should not have the same number of words" do
          @line2.words.length.should_not == @line.words.length
        end

        it "should not have the same display sentence" do
          @line2.display.should_not == @line.display
        end
        
      end
      
    end
    
  end
  
  describe "a line of programmatic text" do
    before(:each) do
      @text = "lie by SHOUT poetry primeval SHOUT disaster measure encircles seen death watches"
      @line = MarkovLine.line_from_prog_text(@text, @lang)
    end

    it "should display properly" do
      @line.display.should == "Lie by POETRY primeval DISASTER measure encircles seen death watches"
    end
    
    it "should only contain MarkovWords" do
      @line.words.each do |word_hash|
        word_hash[:word].class.should == MarkovWord
      end
    end
    
  end
  
  
end

