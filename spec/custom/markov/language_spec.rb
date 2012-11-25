describe Markov::Language do
  subject { Markov::Language.new.add_snippet(work_content) }

  it "should have the word 'you'" do
    expect( subject.fetch("you") ).to_not be_nil
  end

  it "you should not be the begin" do
    expect( subject.fetch("you") ).to_not be_begin
  end

  it "should have a :__begin__" do
    expect( subject.fetch(:__begin__) ).to_not be_nil
  end

  it ":__begin__ should be the begin" do
    expect( subject.fetch(:__begin__) ).to be_begin
  end

  it "should have the word ','" do
    expect( subject.fetch(',') ).to_not be_nil
  end

  it "should have all of its words be Markov::Word" do
    subject.words(true).each do |word|
      expect( subject.fetch(word) ).to be_an_instance_of Markov::Word
    end
  end

  describe "a word that begins a sentence" do
    let(:word) { subject.fetch('take') }

    it "should not be nil" do
      expect( word ).to_not be_nil
    end

    it "should be a sentence begin" do
      expect( word ).to be_sentence_begin
    end

    it "should not be the begin" do
      expect( word ).to_not be_begin
    end
  end

  context "words with punctuation attached" do
    it "should have the word 'god'" do
      expect( subject.fetch('god') ).to_not be_nil
    end

    it "should not have the word 'god!'" do
      expect( subject.fetch('god!') ).to be_nil
    end
  end


  context "words which are always capitalized" do
    it "should have the word 'i'" do
      expect( subject.fetch('i') ).to_not be_nil
    end
  end
end
