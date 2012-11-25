include MarkovHelper

describe Markov::Line do
  shared_examples_for "any line" do
    it "it's display length should equal it's num_chars" do
      @line.display.length.should == @line.num_chars + %{<p>}.length + %{</p>}.length
    end

  end

  let(:lang) { poe_language }

  before(:all) do
    @lang = poe_language
  end

  describe ".+" do
    let(:wd) { double() }

    it "should be able to + a WordDisplayer" do
      line = Markov::Line.new
      line += wd
      expect(line.length).to eq(1)
    end

  end

  describe "basic adding of words" do
    before(:each) do
      @line = Markov::Line.new
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
        @line2 = Markov::Line.line_from_prog_text(@text, @lang)
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
      @line = Markov::Line.line_from_prog_text(@text, @lang)
    end

    it "should display properly" do
      @line.display.should == display_line("Lie by POETRY primeval DISASTER measure encircles seen death watches")
    end

    it "should not be deleted" do
      @line.should_not be_deleted
    end

    describe "after being marked as deleted" do
      before(:each) do
        @line.mark_as_deleted!
      end

      it "should be deleted" do
        @line.should be_deleted
      end

    end

  end

  describe "when marked as from first_parent" do
    before(:each) do
      @line = @lang.gen_line
      @line.mark_as_from_first_parent!
    end

    it "should have a display with the right tags" do
      @line.display.should =~ /^<p><span class="from-first-parent">.*?<\/span><\/p>$/
    end
  end

  describe "when marked as from second_parent" do
    before(:each) do
      @line = @lang.gen_line
      @line.mark_as_from_second_parent!
    end

    it "should have a display with the right tags" do
      @line.display.should =~ /^<p><span class="from-second-parent">.*?<\/span><\/p>$/
    end
  end

end

