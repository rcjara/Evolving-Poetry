include MarkovHelper

describe Markov::Word do
  let(:a)         { Markov::Word.new('a') }
  let(:the)       { Markov::Word.new('the') }

  context "==" do
    subject { Markov::Word.new('word') }

    it "should equal a word that was made with the same inputs" do
      second_word = Markov::Word.new('word')
      expect( subject ).to eq(second_word)
    end

    it "should not equal a word that was made the same way and then altered" do
      second_word = Markov::Word.new('word')
      second_word.add_text('Word')
      expect( subject ).not_to eq(second_word)
    end
  end

  context "#new" do
    context "a simple word" do
      subject { Markov::Word.new("test") }

      its(:identifier)  { should eq("test") }
      its(:count)       { should eq(1) }
      its(:shout_count) { should eq(0) }
      its(:speak_count) { should eq(1) }

      it { should_not be_proper }
      it { should_not be_shoutable }
      it { should     be_speakable }

      it { should_not be_begin }
      it { should_not be_end }
      it { should_not be_sentence_end }
    end

    context "begin" do
      subject { Markov::Word.new(:__begin__) }

      it { should  be_begin }
    end

    context "end" do
      subject { Markov::Word.new(:__end__) }

      it { should  be_end }
    end

    context "a shouted word" do
      subject { Markov::Word.new("TEST") }

      its(:shout_count) { should eq(1) }
      its(:speak_count) { should eq(0) }

      it { should be_proper }
      it { should be_shoutable }
      it { should_not be_speakable }
    end

    context "a proper word" do
      subject { Markov::Word.new("Test") }

      it { should be_proper }
      it { should be_speakable }
      it { should_not be_shoutable }
    end

    context "punctuation" do
      it "should register as punctuation" do
        %w{. , : ; ! ?}.each do |punct|
          expect( Markov::Word.new(punct) ).to be_punctuation
        end
      end

      it "should register as sentence end where appropriate" do
        %w{. ! ?}.each do |punct|
          expect( Markov::Word.new(punct) ).to be_sentence_end
        end
      end

      it "should not register as a sentence end where innappropriate" do
        %w{, : ;}.each do |punct|
          expect( Markov::Word.new(punct) ).to_not be_sentence_end
        end
      end

    end
  end

  context ".add_text" do
    subject do
      Markov::Word.new('TEST').tap do |word|
        %w{Test test TEST}.each { |ident| word.add_text(ident) }
      end
    end

    its(:count)       { should eq(4) }
    its(:shout_count) { should eq(2) }
    its(:speak_count) { should eq(2) }

    it { should_not be_proper }
    it { should be_shoutable }
    it { should be_speakable }
  end
end
