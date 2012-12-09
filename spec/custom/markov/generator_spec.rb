include MarkovHelper

describe Markov::Generator do
  let(:generator) { Markov::Generator.new(language) }

  describe ".generate_line" do
    subject { generator }

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
    let(:language) { Markov::Language.new.add_snippet(text) }
    let(:line)     { generator.generate_line }
    subject        { generator.alter_line(line) }

    context "with a contrived language" do
      let(:text)      { 'A b c. A b d.' }

      it { should_not be_empty }
      its(:num_chars) { should be > 0 }
      its(:num_chars) { should be <= language.limit }

      it "should show that the line was altered" do
        #should create a better way to test that the line was altered
        expect( subject.tags_at_index(2) ).to  include(:beginalteredtext)
        expect( subject.tags_at_index(-1) ).to include(:endspan)
      end

      it "should not have the same words as the old line" do
        old_words = line.word_displayers.map(&:word)
        3.times do
          new_words = generator.alter_line(line)
                               .word_displayers
                               .map(&:word)
          expect(new_words).to_not eq(old_words)
        end
      end
    end

    context "with a language that is impossible to alter" do
      let(:text) { 'a b c d.' }

      it "should return that there are no available indices for altering" do
        expect( subject ).to eq(Markov::Generator::NoAvailableIndicesForAltering)
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

