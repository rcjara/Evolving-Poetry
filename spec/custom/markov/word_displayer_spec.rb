describe Markov::WordDisplayer do
  let(:word) { double( identifier: "word",
                       proper?: false,
                       punctuation?: false ) }
  let(:tags) { [] }
  subject { Markov::WordDisplayer.new(word, tags) }

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
end

