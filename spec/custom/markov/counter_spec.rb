describe Markov::Counter do
  describe "on creation" do
    it "should have a count of zero" do
      expect(subject.count).to eq(0)
    end

    it "should show any words having a count of zero" do
      expect(subject['word']).to eq(0)
    end

  end

  describe ".add_item" do
    describe "after adding one item" do
      subject {
        Markov::Counter.new.tap do |c|
          c.add_item("hello")
        end
      }

      it "should have a count of one" do
        expect( subject.count ).to eq(1)
      end

      it "should show that 'hello' has one a count of one" do
        expect( subject['hello'] ).to eq(1)
      end
    end
  end

  describe ".get_random_item" do
    describe "from a counter with two items" do
      subject {
        Markov::Counter.new.tap do |c|
          c.add_item('hello')
          c.add_item('goodbye')
        end
      }

      it "should be able to get back a word" do
        expect( subject.get_random_item ).to match /^hello|goodbye$/
      end

      it "should get all of its items eventually" do
        results = Set.new
        10.times { results.add( subject.get_random_item ) }
        expect( results ).to eq( Set.new(['hello', 'goodbye']) )
      end

      it "should be able to exclude an item and only get back the other" do
        10.times do
          expect( subject.get_random_item('hello') ).to eq('goodbye')
        end
      end

      it "should raise an error if you exclude too many items" do
        expect { subject.get_random_item('hello', 'goodbye') }.to raise_error(Markov::ExcludeTooManyItemsException)
      end

    end

  end

end

