describe Markov::Language do

  describe "#new" do
    its(:tokens) { should be_empty }
    its(:limit) { should eq(Constants::MAX_NUM_CHARS) }
  end

  describe ".add_snippet" do
    subject { Markov::Language.new.add_snippet(snippet) }

    context "a snippet with only one word repeated" do
      let(:snippet) { "THE " * 10 }

      its(:num_words) { should eq(1) }
      its(:tokens)    { should include('the') }
    end
  end

  describe ".get_random_child_for" do
    context "a language with only one possible path" do
      subject { Markov::Language.new.add_snippet(snippet) }
      let(:snippet) { 'a b c.' }

      it "should have a counter for 'a'" do
        expect( subject.counts[:backward][['a']] ).to be_an_instance_of(Markov::Counter)
      end

      it "should return the appropriate token for 'a'" do
        expect( subject.fetch_random_child_for(['a']) ).to eq('b')
      end

      it "should return the appropriate token for 'c'" do
        expect( subject.fetch_random_child_for(['c'], :forward) ).to eq('.')
      end

      it "should return nil when excluding the only path" do
        expect(
          subject.fetch_random_child_for( ['a'], :forward, Set.new(['b']) )
        ).to be_nil
      end

      it "should return the appropriate token for backward" do
        expect( subject.fetch_random_child_for( ['b'], :backward) ).to eq('a')
      end
    end

    context "a language with an order of 3" do
      subject { Markov::Language.new(3).add_snippet(snippet) }
      let(:snippet) { 'a b c.' }

      it "should get the right token for 3rd order" do
        expect( subject.fetch_random_child_for(%w[a b c]) ).to eq('.')
      end

      it "should get the right token for 2nd order" do
        expect( subject.fetch_random_child_for(%w[a b]) ).to eq('c')
      end

      it "should get the right token for 3rd order" do
        expect( subject.fetch_random_child_for(%w[a]) ).to eq('b')
      end
    end
  end

  context ".multiple_children_for" do
    subject { Markov::Language.new.add_snippet(snippet) }
    let(:snippet) { 'a a b.' }

    it "should have multiple children for 'a'" do
      expect( subject.multiple_children_for?(['a'], :forward) ).to be_true
    end

    it "should have multiple children for 'b'" do
      expect( subject.multiple_children_for?(['b'], :forward) ).to be_false
    end

    it "should raise an error when asked about an impossible combination" do
      expect { subject.multiple_children_for?(['c']) }
        .to raise_error(Markov::Language::InvalidPrecedingTokensException)
    end

  end

  context ".split into sentences" do
    it "should get one sentence for text without sentence ends" do
      expect( subject.split_into_sentences("hello").length ).to eq(1)
    end

    it "should get two sentences for text without sentence ends" do
      expect( subject.split_into_sentences("Hello there. Sexy.").length ).to eq(2)
    end
  end


  context "real world example integration example" do
    subject { Markov::Language.new.add_snippet(work_content) }

    its(:tokens) { should_not be_empty }

    it "should have a __begin__ for each sentence" do
      expect( subject.fetch(:__begin__).count ).to be > 5
    end

    it "should have a word that ends the snippet" do
      expect( subject.fetch(:__end__).count ).to be > 5
    end

    it "should have words that don't begin" do
      expect( subject.fetch("you") ).to_not be_begin
    end

    it "should have some punctuation" do
      expect( subject.fetch('!') ).to_not be_nil
    end

    it "should not have words with punctuation attached" do
      expect( subject.fetch('god!') ).to be_nil
    end


    it "should have all of its words be Markov::Word" do
      subject.tokens(true).each do |token|
        expect( subject.fetch(token) ).to be_an_instance_of Markov::Word
      end
    end

    it "should have proper nouns" do
      expect( subject.fetch('i') ).to be_proper
    end
  end

end
