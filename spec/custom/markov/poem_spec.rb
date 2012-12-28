include MarkovHelper

describe Markov::Poem do
  let(:text) { 'Take this kiss upon the brow! And then the raven.' }
  let(:lang) { Markov::Language.new.add_snippet(text) }
  let(:generator) { Markov::Generator.new(lang) }

  describe "new text tags" do
    let(:prog_text) { "BEGINNEWTEXT take this ENDSPAN kiss upon the brow !" }

    describe "without stripping tags" do
      let(:poem) { Markov::Poem.new_from_prog_text(prog_text, lang) }

      it "should display properly" do
        expect( poem.display ).to eq(
                display_line(%{<span class="new-text"> Take this kiss</span> upon the brow!}))
      end

      it "should have the right programmatic text" do
        expect( poem.to_prog_text ).to eq(prog_text)
      end

    end

    describe "with stripping out tags" do
      let(:poem) { Markov::Poem.new_from_prog_text(prog_text, lang, {:strip => true}) }

      it "should display properly" do
        expect( poem.display ).to eq(display_line(%{Take this kiss upon the brow!}))
      end

      it "should have the right programmatic text" do
        expect( poem.to_prog_text ).to eq("take this kiss upon the brow !")
      end

    end
  end

  describe "deleted text tags" do
    let(:prog_text) { "BEGINDELETED take ENDDELETED this BREAK kiss upon the brow !" }

    describe "without stripping tags" do
      let(:poem) { Markov::Poem.new_from_prog_text(prog_text, lang) }

      it "should display properly" do
        expect( poem.display ).to eq(
            %{<p><span class="deleted-text"> Take this</span></p>\n<p>Kiss upon the brow!</p>})
      end

      it "should have the right programmatic text" do
        expect( poem.to_prog_text ).to eq(prog_text)
      end
    end

    describe "with stripping out tags" do
      let(:poem) { Markov::Poem.new_from_prog_text(prog_text, lang, :strip => true) }

      it "should display properly" do
        expect( poem.display ).to eq(display_line(%{Kiss upon the brow!}))
      end

      it "should have the right programmatic text" do
        expect( poem.to_prog_text ).to eq("kiss upon the brow !")
      end
    end
  end

  describe "sexual reproduction" do
    let(:poem1) { generator.generate_poem(6) }
    let(:poem2) { generator.generate_poem(4) }
    let(:child) { poem1.sexually_reproduce_with(poem2, lang) }

    describe "poem1.half_lines" do
      it "should have 3 lines" do
        expect( poem1.half_lines.length ).to eq(3)
      end
    end

    describe "poem2.half_lines" do
      it "should have 2 lines" do
        expect( poem2.half_lines.length ).to eq(2)
      end
    end

    it "should have 5 lines" do
      expect( child.length ).to eq(5)
    end

    it "should have 3 lines from p1 in its programmatic text" do
      expect( child.to_prog_text.scan(/FROMFIRSTPARENT/).length ).to eq(3)
    end

    it "should have 3 lines from p1 in its display text" do
      expect( child.display.scan(/\<span class\=\"from-first-parent\"\>/).length ).to eq(3)
    end

    it "should have 2 lines from p2 in its programmatic text" do
      expect( child.to_prog_text.scan(/FROMSECONDPARENT/).length ).to eq(2)
    end

    it "should have 2 lines from p2 in its display text" do
      expect( child.display.scan(/\<span class\=\"from-second-parent\"\>/).length ).to eq(2)
    end

  end


  describe "multiline stripping" do
    let(:prog_text) { "take BEGINDELETED this kiss ENDDELETED upon BREAK BEGINDELETED the brow ENDDELETED BREAK BEGINNEWTEXT and ENDSPAN raven !" }
    let(:poem) { Markov::Poem.new_from_prog_text(prog_text, lang, :strip => true) }

    it "should have the right programmatic text" do
      expect( poem.to_prog_text ).to eq("take BREAK and raven !")
    end

    it "should display properly" do
      expect( poem.display ).to eq(%{<p>Take</p>\n<p>And raven!</p>})
    end

  end

  describe ".add_line" do
    subject { poem.add_line(generator) }

    context "a five line poem" do
      let(:poem) { generator.generate_poem(5) }

      it "should include a new text tag" do
        expect( subject.display).to match(/\<span class\="new-text"\>/)
      end

      its(:length) { should == 6 }
    end
  end

  describe ".delete_line" do
    context "a five line poem" do
      let(:poem) { generator.generate_poem(5) }

      describe "delete a single line" do
        subject { poem.delete_line }

        its(:length)          { should == 5 }
        its(:undeleted_lines) { should == 4 }

        it "should have some deleted text" do
          expect( subject.to_prog_text ).to match(/BEGINDELETED.*?ENDDELETED/)
        end
      end
    end
  end

  describe "altering the tail of a line" do
    let(:poem) { generator.generate_poem 1 }
    subject { poem.alter_a_tail(generator) }

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

  describe "altering the front of a line" do
    let(:poem) { generator.generate_poem 1 }
    subject { poem.alter_a_front(generator) }

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

