include MarkovHelper

describe Markov::Evolver do
  let(:evolver) { Markov::Evolver.new(language) }

  describe ".new_line" do
    subject { evolver }

    context "with a real world language" do
      let(:language) { poe_language }

      it "should be able to generate a line with multiple characters" do
        expect( subject.new_line.num_chars ).to be > 0
      end
    end

    context "with a language very unlikely to reach a sentence end" do
      let(:text)     { 'the ' * 1 + 'end.' }
      let(:language) { Markov::Language.new.add_snippet(text) }

      it "should be within the character limit" do
        3.times do
          expect( subject.new_line.num_chars ).to be <= language.limit
        end
      end

    end
  end

  describe ".new_poem" do
    context "with a contrived language" do
      let(:language)  { Markov::Language.new.add_snippet(text) }
      let(:text) { 'A b c. A b d. A c d.' }

      it "the poem's length should be more than one" do
        3.times do
          poem = evolver.new_poem
          expect( poem.length ).to be > 1
        end
      end

      it "the poem's length should be less than eight" do
        3.times do
          poem = evolver.new_poem
          expect( poem.length ).to be < 8
        end
      end

      it "should be able to generate a poem with a set number of lines" do
        poem = evolver.new_poem(6)
        expect( poem.length ).to eq(6)
      end

    end
  end


  describe ".alter_line" do
    let(:language)  { Markov::Language.new.add_snippet(text) }
    let(:evolver) { Markov::Evolver.new(language) }

    subject { evolver.alter_line(line) }

    context "with a contrived language" do
      let(:text)      { 'A b c. A b d.' }
      let(:line)      { Markov::Line.new_from_prog_text('a b c .', language)  }

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
          new_words = evolver.alter_line(line)
                               .word_displayers
                               .map(&:word)
          expect(new_words).to_not eq(old_words)
        end
      end
    end

    context "with a language that is impossible to alter" do
      let(:text) { 'a b c d.' }
      let(:line) { Markov::Line.new_from_prog_text('a b c .', language)  }

      it "should return that there are no available indices for altering" do
        expect( subject ).to eq(Markov::Evolver::NoAvailableIndicesForAltering)
      end
    end
  end

  describe ".alter_beginning" do
    let(:language)  { Markov::Language.new.add_snippet(text) }
    let(:evolver) { Markov::Evolver.new(language) }
    subject { evolver.alter_beginning(line) }

    context "with a contrived language" do
      let(:line) { Markov::Line.new_from_prog_text('a c d .', language)  }
      let(:text) { 'A b d. A c d.' }

      it { should_not be_empty }
      its(:num_chars) { should be > 0 }
      its(:num_chars) { should be <= language.limit }

      it "sanity check for alterable indices" do
        expect( evolver.alterable_indices(line, :backward) ).to eq([2])
      end


      it "should show that the line was altered" do
        #should create a better way to test that the line was altered
        expect( subject.tags_at_index(0) ).to include(:beginalteredtext)
        expect( subject.tags_at_index(1) ).to include(:endspan)
      end

      it "should not have the same words as the old line" do
        old_words = line.word_displayers.map(&:word)
        3.times do
          new_words = evolver.alter_beginning(line)
                               .word_displayers
                               .map(&:word)
          expect(new_words).to_not eq(old_words)
        end
      end
    end
  end

  describe ".alterable_indices" do
    subject { evolver }

    let(:language) { Markov::Language.new.add_snippet(text) }
    let(:text)     { 'a a b' }
    let(:line)     { double(tokens: %w[a a a b b a]) }

    it "should get the right indices forward" do
      expect( subject.alterable_indices(line, :forward) ).to eq([1, 2, 5])
    end

    it "should get the right indices backward" do
      expect( subject.alterable_indices(line, :backward) ).to eq([0, 1, 2])
    end

    it "should work backwards for 'a'" do
      expect( language.multiple_children_for?(['a'], :backward) ).to be_true
    end

    it "should work backwards for 'b'" do
      expect( language.multiple_children_for?(['b'], :backward) ).to be_false
    end
  end
end

