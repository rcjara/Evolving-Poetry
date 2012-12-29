include MarkovHelper

describe Markov::Poem do
  let(:text) { 'Take this kiss upon the brow! And then the raven.' }
  let(:lang) { Markov::Language.new.add_snippet(text) }
  let(:evolver) { Markov::Evolver.new(lang) }

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

  describe ".half_lines" do
    let(:prog_text) { "take this BREAK kiss upon BREAK the brow !" }
    let(:poem) { Markov::Poem.new_from_prog_text(prog_text, lang) }

    subject { poem.half_lines }

    it "should be half the length of the poem" do
      expect( subject.length ).to eq(poem.length / 2)
    end
  end

  describe ".insert_line_at" do
    let(:prog_text) { "take this BREAK kiss upon BREAK the brow !" }
    let(:line_text) { "then the raven" }
    let(:new_line)  { Markov::Line.new_from_prog_text(line_text, lang) }
    let(:poem)      { Markov::Poem.new_from_prog_text(prog_text, lang) }

    subject { poem.insert_line_at(new_line, 1) }

    it "should have the new line at the right index" do
      expect( subject.lines[1].to_prog_text ).to eq(line_text)
    end

    it "should have one extra line" do
      expect( subject.length ).to eq(poem.length + 1)
    end
  end

  describe ".replace_line_at" do
    let(:prog_text) { "take this BREAK kiss upon BREAK the brow !" }
    let(:line_text) { "then the raven" }
    let(:new_line)  { Markov::Line.new_from_prog_text(line_text, lang) }
    let(:poem)      { Markov::Poem.new_from_prog_text(prog_text, lang) }

    subject { poem.replace_line_at(new_line, 1) }

    it "should have the new line at the right index" do
      expect( subject.lines[1].to_prog_text ).to eq(line_text)
    end

    it "should have the same number of lines" do
      expect( subject.length ).to eq(poem.length)
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
end

