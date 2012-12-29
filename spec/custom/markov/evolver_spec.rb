include MarkovHelper

describe Markov::Evolver do
  let(:evolver) { Markov::Evolver.new(language) }

  describe ".new_line" do
    subject { evolver }

    context "with a language very unlikely to reach a sentence end" do
      let(:text)     { 'the ' * 1 + 'end.' }
      let(:language) { Markov::Language.new.add_snippet(text) }

      it "should be within the character limit" do
        3.times do
          expect( subject.new_line.num_chars ).to be > 0
          expect( subject.new_line.num_chars ).to be <= language.limit
        end
      end

    end
  end

  describe ".new_poem" do
    context "with a contrived language" do
      let(:text) { 'A b c. A b d. A c d.' }
      let(:language)  { Markov::Language.new.add_snippet(text) }

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


  describe "Line Alteration" do

    describe ".alter_line_tail" do
      let(:language)  { Markov::Language.new.add_snippet(text) }

      subject { evolver.alter_line_tail(line) }

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
            new_words = evolver.alter_line_tail(line)
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

    describe ".alter_line_front" do
      let(:language)  { Markov::Language.new.add_snippet(text) }
      subject { evolver.alter_line_front(line) }

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
            new_words = evolver.alter_line_front(line)
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

  describe "Poem Evolution" do
    let(:text)     { 'a a b b' }
    let(:language) { Markov::Language.new.add_snippet(text) }

    describe ".mutate" do
      let(:poem) { evolver.new_poem(3) }

      it "should always alter the poem" do
        5.times do
          new_poem = evolver.mutate(poem)
          expect( new_poem.display ).not_to eq(poem.display)
        end
      end

      context "when altering / deleting lines isn't working" do
        let(:bad_evolver) do
          evolver.stub(:delete_line_from_poem).and_return(:no_indices_available)
          evolver.stub(:alter_a_front).and_return(:bad_continue_result)
          evolver.stub(:alter_a_tail).and_return(:bad_continue_result)
          evolver
        end

        subject { bad_evolver.mutate(poem) }

        it "should always have one more line than before" do
          20.times do
            expect( subject.length ).to eq(poem.length + 1)
          end
        end
      end

    end

    describe ".mate_poems" do
      subject { evolver.mate_poems(poem1, poem2) }

      context "from parents with lengths 6 and 4" do
        let(:poem1)    { evolver.new_poem(6) }
        let(:poem2)    { evolver.new_poem(4) }

        its(:length) { should == 5 }

        it "should have 3 lines from p1 in its programmatic text" do
          expect( subject.to_prog_text.scan(/FROMFIRSTPARENT/).length ).to eq(3)
        end

        it "should have 2 lines from p2 in its programmatic text" do
          expect( subject.to_prog_text.scan(/FROMSECONDPARENT/).length ).to eq(2)
        end
      end
    end

    describe ".add_line_to_poem" do
      subject { evolver.add_line_to_poem(poem) }

      context "a five line poem" do
        let(:poem) { evolver.new_poem(5) }

        it "should include a new text tag" do
          expect( subject.display).to match(/\<span class\="new-text"\>/)
        end

        its(:length) { should == 6 }
      end
    end

    describe ".delete_line_from_poem" do
      subject { evolver.delete_line_from_poem(poem) }

      context "given a five line poem" do
        let(:poem) { evolver.new_poem(5) }

        its(:length)          { should == 5 }
        its(:undeleted_lines) { should == 4 }
      end

      context "given a poem with no no lines to alter" do
        let(:poem) { double("unalterable_poem", unaltered_indices: []) }

        it "should return a no available indices for altering result" do
          expect( subject ).to eq(Markov::Evolver::NoAvailableIndicesForAltering)
        end

      end
    end

    describe ".alter_a_tail" do
      let(:poem) { evolver.new_poem 1 }
      subject { evolver.alter_a_tail(poem) }

      it "should not look like it used to" do
        expect( subject.display ).to_not eq(poem.display)
      end

      it "should still have the last word in common" do
        first_word = poem.to_prog_text.split(/\s/).first
        expect( subject.to_prog_text.split(/\s/).first ).to eq(first_word)
      end

      it "should still have a length of one" do
        expect( subject.length ).to eq(1)
      end
    end

    describe ".alter_a_front" do
      let(:poem) { evolver.new_poem 1 }
      subject { evolver.alter_a_front(poem) }

      it "should not look like it used to" do
        expect( subject.display ).to_not eq(poem.display)
      end

      it "should still have the last word in common" do
        last_word = poem.to_prog_text.split(/\s/).last
        expect( subject.to_prog_text.split(/\s/).last ).to eq(last_word)
      end

      it "should still have a length of one" do
        expect( subject.length ).to eq(1)
      end
    end

  end
end

