describe Markov::Counter do
  context "on creation" do
    it { should be_empty }
    its(:count) { should eq(0) }

    it "should show any words having a count of zero" do
      expect(subject['word']).to eq(0)
    end

  end

  context ".add_item" do
    context "after adding one item" do
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

  context ".get_random_item" do
    context "from a counter with two items" do
      let(:hello)   { double(identifier: 'hello') }
      let(:goodbye) { double(identifier: 'goodbye') }

      subject {
        Markov::Counter.new.tap do |c|
          c.add_item(hello)
          c.add_item(goodbye)
        end
      }

      it "should be able to get back a word" do
        expect( subject.get_random_item.identifier ).to match /^hello|goodbye$/
      end

      it "should get all of its items eventually" do
        results = Set.new
        10.times { results.add( subject.get_random_item ) }
        expect( results ).to eq( Set.new([hello, goodbye]) )
      end

      it "should be able to exclude an item and only get back the other" do
        10.times do
          expect( subject.get_random_item(hello) ).to eq(goodbye)
        end
      end

      it "should return nil if too many items are excluded" do
        expect( subject.get_random_item(hello, goodbye) ).to be_nil
      end

    end

  end

end

