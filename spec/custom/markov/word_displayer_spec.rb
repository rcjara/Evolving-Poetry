describe Markov::WordDisplayer do
  let(:default_word_attributes) do
    { identifier: "word",
      proper?: false,
      punctuation?: false }
  end

  let(:word) { double(default_word_attributes) }
  let(:tags) { [] }

  subject { Markov::WordDisplayer.new(word, tags) }

  context "#new_with_rand_tags" do
    subject { Markov::WordDisplayer.new_with_rand_tags(word) }

    context "a word guaranteed to be shouted" do
      let(:word) do
        double( {count: 1, shout_count: 1}.merge(default_word_attributes) )
      end

      its(:tags) { should include(:shout) }
    end

    context "a word guaranteed to be spoken" do
      let(:word) do
        double( {count: 1, shout_count: 0}.merge(default_word_attributes) )
      end

      its(:tags) { should_not include(:shout) }
    end
  end

  context ".display" do
    context "without any tags should display its word properly" do

      it "if the word has no attributes" do
        expect(subject.display).to eq(" word")
      end

      it "if the word is punctuation" do
        word.stub({ punctuation?: true })
        expect( subject.display ).to eq("word")
      end

      it "if the word is proper" do
        word.stub({ proper?: true })
        expect( subject.display ).to eq(" Word")
      end

      it "if the word is the beginning of a sentence" do
        expect( subject.display(true) ).to eq(" Word")
      end
    end

    context "with one tag" do
      let(:tags) { [:shout] }

      it "should display properly" do
        expect( subject.display ).to eq(" WORD")
      end

    end

    context "with multiple tags" do
      let(:tags) { [:shout, :beginalteredtext, :endspan] }

      it "should display properply" do
        expect( subject.display ).to eq(%{<span class="altered-text">} + " WORD" + %{</span>})
      end
    end

    context "with an unsupported tag" do
      let(:tags) { [:something_unsupported] }

      it "should raise an error" do
        expect { subject.display }.to raise_error(Markov::UnsupportedTagError)
      end
    end
  end

  context ".add_tag" do
    it "should be able to receive a tag" do
      subject.add_tag(:beginnewtext)
      expect(subject.has_tag? :beginnewtext).to be_true
    end
  end

  context ".to_prog_text" do
    context "A WordDisplayer with no tags" do
      it "should be able to convert itself to programmatic text" do
        expect(subject.to_prog_text).to eq("word")
      end
    end

    context "A WordDisplayer with tags" do
      let(:tags) { [:beginnewtext, :shout] }

      it "should be able to convert itself to programmatic text including the tags" do
        expect(subject.to_prog_text).to eq("BEGINNEWTEXT SHOUT word")
      end
    end
  end

  context "#word_shout_prob" do
    it "should return a probability" do
      word = double('word')
      word.should_receive(:shout_count).and_return(3)
      word.should_receive(:count).and_return(4)
      expect( Markov::WordDisplayer.word_shout_prob(word) ).to eq(0.75)
    end
  end
end

