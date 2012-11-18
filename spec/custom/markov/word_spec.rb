include MarkovHelper

describe Markov::Word do
  context "==" do
    subject { Markov::Word.new('word', 'a') }

    it "should equal a word that was made with the same inputs" do
      second_word = Markov::Word.new('word', 'a')
      expect(subject).to eq(second_word)
    end

    it "should not equal a word that was made the same way and then altered" do

      second_word = Markov::Word.new('word', 'a')
      second_word.add_parent('the', 'word', false)
      expect(subject).not_to eq(second_word)
    end
  end

  shared_examples_for "any word" do
    it "should have an identifier that is downcased" do
      @word.identifier.to_s.should == @word.identifier.to_s.downcase
    end
  end

  shared_examples_for "a non-terminating word" do
    it "should show that it doesn't terminate" do
      @word.terminates?.should == false
    end
  end

  shared_examples_for "a word that hasn't had any children added" do
    it "should show that it has no children" do
      @word.num_children.should == 0
    end

    it "should show a children count of 0" do
      @word.children_count.should == 0
    end

    it_should_behave_like "a non-terminating word"
  end

  shared_examples_for "a word that hasn't had any parents added" do
    it "should show that it has 1 parent" do
      @word.num_parents.should == 0
    end

    it "should show a parents count of 1" do
      @word.parents_count.should == 0
    end
  end

  context "simple word" do
    before(:each) do
      @word = Markov::Word.new("TEST", :__begin__)
    end

    it "should have a lower case identifier" do
      @word.identifier.should == "test"
    end

    it "should say that it is proper" do
      @word.proper?.should == true
    end

    it "should say that it can be all caps" do
      @word.shoutable?.should == true
    end

    it "should not yet be speakable" do
      @word.speakable?.should == false
    end

    it "should have a shout count of one" do
      @word.shout_count.should == 1
    end

    it "should have a speak count of zero" do
      @word.speak_count.should == 0
    end

    it_should_behave_like "any word"
    it_should_behave_like "a word that hasn't had any children added"
    it_should_behave_like "a word that hasn't had any parents added"

    it "should show that it has a count of one" do
      @word.count.should == 1
    end

    context "on adding some capitalized parent instances" do
      before(:each) do
        @parents = ["a", "the"]
        @added_words = [ [:__begin__, "Test"], ["a", "TEST"],["the","Test"] ]
        @added_words.each { |word_pair| @word.add_parent(*word_pair, false) }
      end

      it "should show a count of four" do
        @word.count.should == 4
      end

      it "should be speakable" do
        @word.speakable?.should == true
      end

      it "should be proper" do
        @word.proper?.should == true
      end

      it "should have two parents" do
        @word.num_parents.should == 2
      end

      it "should have a parents count of 2" do
        @word.parents_count.should == 2
      end

      it "should have a shout count of 2" do
        @word.shout_count.should == 2
      end

      it "should have a speak count of 2" do
        @word.speak_count.should == 2
      end

      it "should be able to get one of its parents" do
        @parents.include?(@word.get_random_parent).should == true
      end

      it "should get all of its parents eventually" do
        results = (1..30).collect { |throw_away| @word.get_random_parent }
        results.uniq.sort{ |a,b| a.to_s <=> b.to_s }.should == @parents.sort{ |a,b| a.to_s <=> b.to_s }
      end

      it_should_behave_like "any word"
      it_should_behave_like "a word that hasn't had any children added"
    end

    context "on adding some uncapitalized children instances" do
      before(:each) do
        @children = ["eats", "sucks", "blows"]
        @added_words = [ ["Test", "eats"],["TEST", "sucks"],["test","blows"] ]
        @children.each { |child| @word.add_child(child) }
      end

      it "should show a count of four" do
        @word.count.should == 1
      end

      it "should have three children" do
        @word.num_children.should == 3
      end

      it "should have a children count of 3" do
        @word.children_count.should == 3
      end

      it "should have a shout count of 1" do
        @word.shout_count.should == 1
      end

      it "should have a speak count of 0" do
        @word.speak_count.should == 0
      end

      it "should be able to get one of its children" do
        @children.include?(@word.get_random_child).should == true
      end

      it "should get all of its children eventually" do
        results = (1..30).collect { |_| @word.get_random_child }
        results.uniq.sort{ |a,b| a.to_s <=> b.to_s }.should == @children.sort{ |a,b| a.to_s <=> b.to_s }
      end

      it_should_behave_like "a word that hasn't had any parents added"
    end

    context "shouting vs. non shouting words" do
      before(:each) do
        @non_shouting_words = ["apple","dog","bear"]
        @shouting_words     = ["APPLE","DOG","BEAR"]
        @non_shouting_markov_words = nouns_to_markov_words(@non_shouting_words)
        @shouting_markov_words = nouns_to_markov_words(@shouting_words)
      end

      it "should have its non-shouting words be non-shouting" do
        @non_shouting_markov_words.each do |word|
          word.should_not be_shoutable
        end
      end

      it "should have its shouting words be shoutable" do
        @shouting_markov_words.each do |word|
          word.should be_shoutable
        end
      end

      it "should have its non-shouting have shout counts of 0" do
        @non_shouting_markov_words.each do |word|
          word.shout_count.should == 0
        end
      end

      it "should have its shouting words have shout counts of 1" do
        @shouting_markov_words.each do |word|
          word.shout_count.should == 1
        end
      end

      it "none of these shouting, non shouting words should equal eachother" do
        all_words = @non_shouting_markov_words + @shouting_markov_words
        all_words.each_with_index do |word, i|
          all_words[(i + 1)..-1].each { |other_word| word.should_not == other_word }
        end
      end

    end

    context "on adding a terminating child" do
      before(:each) do
        @word.add_child
      end

      it "should have a count of two" do
        @word.count.should == 1
      end

      it "should show that it terminates" do
        @word.terminates?.should == true
      end
    end

    context "on creating punctuation words" do
      before(:each) do
        @words = [".", "!", "?", "zaps.", "pow!",
          "fun?", ",", ":", ";", "...."].collect{ |word| Markov::Word.new(word,  :__begin__) }
      end

      it "each word should be punctuation" do
        @words.each { |word| word.punctuation?.should == true  }
      end

      it "the first three words should be sentence endings" do
        @words[0..2].each { |word| word.sentence_end?.should be_true }
      end

      it "the last six words should not be sentence endings" do
        @words[-7..-1].each { |word| word.sentence_end?.should be_false }
      end
    end

    context "on creating non-punctuation words" do
      before(:each) do
        @words = ["this","that","the","other","thing","yay",":)"].collect{ |word| Markov::Word.new(word, :__begin__) }
      end

      it "each word should not be punctuation" do
        @words.each { |word| word.punctuation?.should == false  }
      end

      it "each word should not be a sentence ending" do
        @words.each { |word| word.sentence_end?.should == false  }
      end
    end
  end


end

