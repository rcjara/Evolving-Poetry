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
end

