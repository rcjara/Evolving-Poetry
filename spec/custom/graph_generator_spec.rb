describe GraphGenerator do
  before(:all) do
    @lang = MarkovLanguage.new
    text = File.read( Rails.root.
      join('lib/works/nonsense_welcome.txt').to_s )
    text.split(/\n/)[1...-1].each do |line|
      @lang.add_snippet(line)
    end
  end

  describe "building simplified words" do
    before(:each) do
      @simplified = GraphGenerator::build_simplified_words(@lang, 20)
    end

    it "should build a list with the target number of words" do
      @simplified.length.should == 20
    end

    it "should include a sentence ending" do
      has_sentence_end = @simplified.inject(false) {|m, w| w ||= m.sentence_end? }
      has_sentence_end.should be_true
    end

    describe "finding the ending" do
      before(:each) do
        @ending = GraphGenerator::find_ending(@simplified)
      end

      it "should actually be a sentence end" do
        @ending.should be_sentence_end
      end
    end

    describe "identifying childless parents" do
      it "should definitly be able to find a child for :__begin__" do
        beginning = @simplified[:__begin__]
        beginning.should_not be_nil
        GraphGenerator.dangling?(
          @simplified, beginning).should be_false
      end

      it "should be able to identify childless parents" do
        @simplified.values.each do |mw|
          GraphGenerator.dangling?(
            @simplified, mw).should be_false
        end
      end

      it "shouldn't have a dangler" do
        GraphGenerator::dangler(@simplified).should be_nil
      end
    end

    describe "identifying childless parents (rigged)" do
      before(:each) do
        @simplified.delete("a")
        @simplified.delete("have")
      end

      it "should be able to identify childless parents (rigged)" do
        @simplified.values.each do |mw|
          GraphGenerator.dangling?(
            @simplified, mw).should be_false
        end
      end

      it "shouldn't have a dangler" do
        GraphGenerator::dangler(@simplified).should be_nil
      end

    end

  end

  describe "simple case" do
    before(:each) do
      keys = [:__begin__, "nonsense", ".", "the"]
      @simplified = {}
      keys.each do |key|
        @simplified[key] = @lang.fetch_word(key)
      end
    end

    it "should have the right simplified state" do
      GraphGenerator::simplified_state(@simplified).should ==
        {
          :__begin__ => ["nonsense", "the"],
          "nonsense" => ["."],
          "the"      => [],
          "."        => []
        }
    end

    it "should have a dangler" do
      GraphGenerator::dangler(@simplified).should_not be_nil
    end

    it "should have 'the' as the dangler" do
      GraphGenerator::dangler(@simplified).identifier.should == "the"
    end

    describe "after adding more words" do
      before(:each) do
        keys = ["poets"]
        keys.each do |key|
          @simplified[key] = @lang.fetch_word(key)
        end
      end

      it "should have the right simplified state" do
        GraphGenerator::simplified_state(@simplified).should ==
          {
            :__begin__ => ["nonsense", "poets", "the"],
            "nonsense" => ["."],
            "the"      => ["poets"],
            "poets"    => ["."],
            "."        => []
          }
      end

      it "shouldn't have a dangler" do
        GraphGenerator::dangler(@simplified).should be_nil
      end

    end

  end

end

