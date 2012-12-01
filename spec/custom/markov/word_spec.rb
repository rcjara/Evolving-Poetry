include MarkovHelper

describe Markov::Word do
  let(:a)         { Markov::Word.new('a') }
  let(:the)       { Markov::Word.new('the') }
  let(:__begin__) { Markov::Word.new(:__begin__) }

  context "==" do
    subject { Markov::Word.new('word').add_parent(a) }

    it "should equal a word that was made with the same inputs" do
      second_word = Markov::Word.new('word').add_parent(a)
      expect( subject ).to eq(second_word)
    end

    it "should not equal a word that was made the same way and then altered" do
      second_word = Markov::Word.new('word').add_parent(a)
      second_word.add_parent(the)
      expect( subject ).not_to eq(second_word)
    end
  end

  context "#new" do
    context "a simple word" do
      subject { Markov::Word.new("test") }

      its(:identifier)  { should == "test" }
      its(:count)       { should == 1 }
      its(:shout_count) { should == 0 }
      its(:speak_count) { should == 1 }

      it { should_not be_proper }
      it { should_not be_shoutable }
      it { should     be_speakable }

      it { should_not be_begin }
      it { should_not be_sentence_begin }
      it { should_not be_sentence_end }

      its(:children) { should be_empty }
      its(:parents)  { should be_empty }
    end

    context "a shouted word" do
      subject { Markov::Word.new("TEST") }

      its(:shout_count) { should == 1 }
      its(:speak_count) { should == 0 }

      it { should be_proper }
      it { should be_shoutable }
      it { should_not be_speakable }
    end

    context "a proper word" do
      subject { Markov::Word.new("Test") }

      it { should be_proper }
      it { should be_speakable }
      it { should_not be_shoutable }
    end

    context "punctuation" do
      it "should register as punctuation" do
        %w{. , : ; ! ?}.each do |punct|
          expect( Markov::Word.new(punct) ).to be_punctuation
        end
      end

      it "should register as sentence end where appropriate" do
        %w{. ! ?}.each do |punct|
          expect( Markov::Word.new(punct) ).to be_sentence_end
        end
      end

      it "should not register as a sentence end where innappropriate" do
        %w{, : ;}.each do |punct|
          expect( Markov::Word.new(punct) ).to_not be_sentence_end
        end
      end

    end
  end

  context ".add_parent" do
    subject { Markov::Word.new("TEST").add_parent(parent) }

    context "begin as parent" do
      let(:parent) { double('parent', begin?: true,
                                      sentence_begin?: false) }

      it { should be_sentence_begin }
      its(:parents)  { should_not be_empty }
    end

    context "add a word ending" do
      let(:parent) { double('parent', begin?: false,
                                      sentence_begin?: true) }

      it { should be_sentence_begin }
      its(:parents)  { should_not be_empty }
    end

    context "a normal word as parent" do
      let(:parent) { double('parent', begin?: false,
                                      sentence_begin?: false) }

      it { should_not be_sentence_begin }
      its(:parents)  { should_not be_empty }

      it "should send messages to the parent" do
        parent = double('parent')
        parent.should_receive(:begin?).and_return(false)
        parent.should_receive(:sentence_begin?).and_return(false)
        Markov::Word.new("hello").add_parent(parent)
      end
    end
  end

  context ".add_text" do
    subject do
      Markov::Word.new('TEST').tap do |word|
        %w{Test test TEST}.each { |ident| word.add_text(ident) }
      end
    end

    its(:count)       { should == 4 }
    its(:shout_count) { should == 2 }
    its(:speak_count) { should == 2 }

    it { should_not be_proper }
    it { should be_shoutable }
    it { should be_speakable }
  end

  context ".add_child" do
    subject { Markov::Word.new("Test").add_child(double) }

    its(:children) { should_not be_empty }
  end

  context ".has_multiple_children?" do
    subject { Markov::Word.new('hello') }

    context "with multiple children" do
      it "should have multiple children if they are different children" do
        child  = Markov::Word.new('child1')
        child2 = Markov::Word.new('child2')
        subject.add_child(child).add_child(child2)
        expect(subject.has_multiple_children?).to be_true
      end

      it "should not have multiple children if they are the same child" do
        child = double('child')
        subject.add_child(child).add_child(child)
        expect(subject.has_multiple_children?).to be_false
      end
    end

    context "without multiple children" do
      it "should show it does not have multiple children" do
        child = double('child')
        subject.add_child(child)
        expect(subject.has_multiple_children?).to be_false
      end
    end
  end

  context ".has_multiple_parents?" do
    subject { Markov::Word.new('hello') }

    context "with multiple parents" do
      it "should have multiple parents if they are different parents" do
        parent  = Markov::Word.new('parent1')
        parent2 = Markov::Word.new('parent2')
        subject.add_parent(parent).add_parent(parent2)
        expect(subject.has_multiple_parents?).to be_true
      end

      it "should not have multiple parents if they are the same parent" do
        parent = double('parent').as_null_object
        subject.add_parent(parent).add_parent(parent)
        expect(subject.has_multiple_parents?).to be_false
      end
    end

    context "without multiple parents" do
      it "should show it does not have multiple parents" do
        parent = double('parent').as_null_object
        subject.add_parent(parent)
        expect(subject.has_multiple_parents?).to be_false
      end
    end
  end

end
