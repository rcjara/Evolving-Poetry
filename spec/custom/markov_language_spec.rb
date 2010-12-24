describe MarkovLanguage do
  before(:each) do
    @lang = MarkovLanguage.new
    @lang.add_snippet(work_content)
  end
  
  it "should have the word 'you'" do
    @lang.fetch_word("you").should_not be_nil
  end
  
  it "should have the word ','" do
    @lang.fetch_word(",").should_not be_nil
  end
  
  it "should have the word '!'" do
    @lang.fetch_word("!").should_not be_nil
  end
  
  it "should have the word '?'" do
    @lang.fetch_word("?").should_not be_nil
  end
  
  it "should have the word 'take'" do
    @lang.fetch_word("take").should_not be_nil
  end
  
  it "should have the word 'god'" do
    @lang.fetch_word("god").should_not be_nil
  end
  
  it "should not have the word 'god!'" do
    @lang.fetch_word("god!").should be_nil
  end
  
  it "should have the word 'i'" do
    @lang.fetch_word("i").should_not be_nil
  end

  describe "the word delimeter regex" do
    before(:each) do
      @words = "Take this kiss upon the brow! ".scan(MarkovLanguage::WORD_REGEX)
    end

    it "should have 7 @words in it" do
      @words.length.should == 7
    end

    it "should have '!' be its last word" do
      @words[-1].should == "!"
    end
    
    it "should have 'Take' as it's first word" do
      @words[0].should == "Take"
    end
    
    
  end
  
  
end
