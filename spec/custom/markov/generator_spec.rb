include MarkovHelper

describe Markov::Generator do
  subject { Markov::Generator.new(language) }

  describe ".generate_line" do
    context "with a real world language" do
      let(:language) { poe_language }

      it "should be able to generate a line multiple characters" do
        expect( subject.generate_line.num_chars ).to be > 0
      end
    end

    context "with a language very unlikely to reach a sentence end" do
      let(:text)     { 'the ' * 1 + 'end.' }
      let(:language) { Markov::Language.new.add_snippet(text) }

      it "should be within the character limit" do
        3.times do
          expect( subject.generate_line.num_chars ).to be <= language.limit
        end
      end

    end
  end

  describe ".alter_line" do
    context "with a contrived language" do
      let(:generator) { Markov::Generator.new(language) }
      let(:text)      { 'A a b. A a c. A b c.' }
      let(:language)  { Markov::Language.new.add_snippet(text) }

      let(:line) do
        line = Markov::Line.new
        while Markov::Generator.alterable_indices(line) ==
              Markov::Generator::NoAvailableIndicesForAltering
          line = generator.generate_line
        end

        line
      end

      subject { generator.alter_line(line) }

      it { should_not be_empty }
      its(:num_chars) { should be > 0 }
      its(:num_chars) { should be <= language.limit }

      it "should not have the same words as the old line" do
        old_words = line.word_displayers.map(&:word)
        10.times do
          new_words = generator.alter_line(line)
                               .word_displayers
                               .map(&:word)
          expect(new_words).to_not eq(old_words)
        end
      end

    end

  end

  describe "#alterable_indices" do
    it "should exclude 0 indices" do
      line = double('indices', multiple_children_indices: [0, 2, 4])
      expect( Markov::Generator.alterable_indices(line) ).to eq([2, 4])
    end

    it "should send multiple_children_indices to the line" do
      line = double
      line.should_receive(:multiple_children_indices).and_return([])
      Markov::Generator.alterable_indices(line)
    end

    it "should return NoAvailableIndicesForAltering if indices is empty" do
      line = double('indices', multiple_children_indices: [])
      expect( Markov::Generator.alterable_indices(line) )
        .to eq(Markov::Generator::NoAvailableIndicesForAltering)
    end
  end
end

