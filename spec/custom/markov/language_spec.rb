describe Markov::Language do

  describe "#new" do
    its(:words) { should be_empty }
    its(:limit) { should eq(Constants::MAX_NUM_CHARS) }
  end

  describe ".add_snippet" do
    subject { Markov::Language.new.add_snippet(snippet) }

    context "a snippet with only one word repeated" do
      let(:snippet) { "THE " * 10 }

      its(:num_words) { should == 1 }
      its(:words)     { should include('the') }
    end
  end

  context "real world example integration example" do
    subject { Markov::Language.new.add_snippet(work_content) }

    its(:words) { should_not be_empty }

    it "should have a word that begins the snippet" do
      expect( subject.fetch(:__begin__) ).to be_begin
    end

    it "should have words that don't begin" do
      expect( subject.fetch("you") ).to_not be_begin
    end

    it "should have words that begins a sentence" do
      expect( subject.fetch('take') ).to be_sentence_begin
    end

    it "should have some punctuation" do
      expect( subject.fetch('!') ).to_not be_nil
    end

    it "should not have words with punctuation attached" do
      expect( subject.fetch('god!') ).to be_nil
    end


    it "should have all of its words be Markov::Word" do
      subject.words(true).each do |word|
        expect( subject.fetch(word) ).to be_an_instance_of Markov::Word
      end
    end

    it "should have proper nouns" do
      expect( subject.fetch('i') ).to be_proper
    end
  end

end
