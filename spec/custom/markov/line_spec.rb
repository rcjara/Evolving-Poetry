include MarkovHelper

describe Markov::Line do
  let(:snippet) { "Take this kiss upon the brow!" }
  let(:lang)    { Markov::Language.new.add_snippet(snippet) }
  let(:basic_line) do
    lang.words[0..5].inject(Markov::Line.new) do |line, word_text|
      markov_word = lang.fetch(word_text)
      line + Markov::WordDisplayer.new(markov_word)
    end
  end

  describe "#new" do
    subject { Markov::Line.new }

    it { should_not be_deleted }
    its(:length)    { should == 0 }
    its(:num_chars) { should == 0 }

    it "should raise an error if you try to mark it" do
      expect { subject.mark!(:some_random_tag) }.to raise_error(Markov::MarkEmptyLineException)
    end
  end

  describe ".+" do
    it "should be able to + a WordDisplayer" do
      line = Markov::Line.new
      line += double()
      expect(line.length).to eq(1)
    end

    context "a line with random words" do
      subject { basic_line }

      it { should_not be_deleted }
      its(:num_chars) { should be > 0 }

      it "should have more characters after adding" do
        old_length  = subject.num_chars
        markov_word = lang.fetch(lang.words[6])
        new_line    = subject + Markov::WordDisplayer.new(markov_word)
        expect( new_line.num_chars).to be > old_length
      end
    end
  end


  describe "#new_from_prog_text" do
    let(:text) { "take this SHOUT kiss upon SHOUT the brow !" }
    subject { Markov::Line.new_from_prog_text(text, lang) }

    its(:display) { should == "<p>Take this KISS upon THE brow!</p>" }
  end

  describe ".to_prog_text" do
    subject { basic_line.to_prog_text }

    it "should contain only all upper or lower case words" do
      subject.split(" ").each do |w|
        expect(w.upcase == w || w.downcase == w).to be_true
      end
    end
  end

  describe "going back and forth between programmatic text" do
    let(:second_line) do
      text = basic_line.to_prog_text
      second_line = Markov::Line.new_from_prog_text(text, lang)
    end

    it "should have the same number of words" do
      expect( basic_line.words.length ).to eq(second_line.words.length)
    end

    it "should have the same display sentence" do
      expect( basic_line.display ).to eq(second_line.display)
    end
  end

  describe ".mark_as_deleted!" do
    shared_examples_for "a deleted sentence" do
      it { should be_deleted }

      it "should have its first word have a begin-deleted tag" do
        expect( subject.words.first.has_tag? :begindeleted ).to be_true
      end

      it "should have its last word have an end-deleted tag" do
        expect( subject.words.last.has_tag? :enddeleted ).to be_true
      end
    end

    context "basic line" do
      subject { basic_line.mark_as_deleted! }

      it_should_behave_like "a deleted sentence"
    end

    context "a sentence with just one word" do
      subject do
        markov_word    = lang.fetch(lang.words.first)
        word_displayer = Markov::WordDisplayer.new(markov_word)
        line           = Markov::Line.new([word_displayer])
        line.mark_as_deleted!
      end

      it_should_behave_like "a deleted sentence"
    end
  end

end



#  describe "a line of programmatic text" do
#    before(:each) do
#
#      @line = Markov::Line.line_from_prog_text(@text, @lang)
#    end
#
#
#    it "should not be deleted" do
#      @line.should_not be_deleted
#    end
#
#    describe "after being marked as deleted" do
#      before(:each) do
#        @line.mark_as_deleted!
#      end
#
#      it "should be deleted" do
#        @line.should be_deleted
#      end
#
#    end
#
#  end
#
#  describe "when marked as from first_parent" do
#    before(:each) do
#      @line = @lang.gen_line
#      @line.mark_as_from_first_parent!
#    end
#
#    it "should have a display with the right tags" do
#      @line.display.should =~ /^<p><span class="from-first-parent">.*?<\/span><\/p>$/
#    end
#  end
#
#  describe "when marked as from second_parent" do
#    before(:each) do
#      @line = @lang.gen_line
#      @line.mark_as_from_second_parent!
#    end
#
#    it "should have a display with the right tags" do
#      @line.display.should =~ /^<p><span class="from-second-parent">.*?<\/span><\/p>$/
#    end
#  end
#
#end

