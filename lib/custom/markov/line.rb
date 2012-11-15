module Markov
  class Line
    attr_reader :words

    def initialize
      @words = []
      @num_chars = 0
    end

    def num_chars
      @num_chars == 0 ? 0 : @num_chars - 1
    end

    def add_word(word, attr = {})
      attr[:shout] = word.should_shout?

      @words << {:word => word, :attr => attr}
      @num_chars += word.display.length
    end

    def push_word(word, attr = {})
      attr[:shout] = word.should_shout?

      @words.insert(0, {:word => word, :attr => attr})
      @num_chars += word.display.length
    end

    def length
      @words.length
    end

    def deleted?
      @words.first[:attr][:begindeleted] && @words.last[:attr][:enddeleted]
    end

    def mark!(begin_tag, end_tag = :endspan)
      @words.first[:attr][begin_tag] = true
      @words.last[:attr][end_tag] = true
    end

    def mark_as_new!
      mark!(:beginnewtext)
    end

    def mark_as_deleted!
      mark!(:begindeleted, :enddeleted)
    end

    def mark_as_from_first_parent!
      mark!(:fromfirstparent)
    end

    def mark_as_from_second_parent!
      mark!(:fromsecondparent)
    end

    def empty?
      @words.empty?
    end

    def add_word_hash(hash)
      @words << hash
    end


    #Removed the last word hash from @words
    #Return whether the remaining word is a valid sentence end
    def remove_last_word
      return nil unless @words.length > 1
      removed = @words.pop

      #question, do I remove the attr from the display?
      #Right now this could only make more characters than it should remove,
      #but in the future, I might have attr for which this makes sense
      @num_chars -= removed[:word].display(removed[:attr]).length

      new_last_word = @words.last[:word]
      new_last_word.terminates? || new_last_word.sentence_end?
    end

    #Removed the first word hash from @words
    #Return whether the remaining word is a valid sentence end
    def remove_first_word
      return nil unless @words.length > 1
      removed = @words.slice!(0)

      #question, do I remove the attr from the display?
      #Right now this could only make more characters than it should remove,
      #but in the future, I might have attr for which this makes sense
      @num_chars -= removed[:word].display(removed[:attr]).length

      new_first_word = @words.first[:word]
      new_first_word.sentence_begin?
    end

    def display(sentence_begin = true)
      sentence = @words.collect do |hash|
        w = hash[:word]
        a = hash[:attr]

        this_begin = sentence_begin
        sentence_begin = w.sentence_end?

        w.display(a, this_begin)
      end.join.strip

      "<p>" + sentence + "</p>"
    end

    def to_prog_text
      @words.collect do |h|
        key_words = ""
        h[:attr].each_pair do |k, val|
          key_words << k.to_s.upcase + " " if val
        end

        key_words + h[:word].identifier
      end.join(" ")
    end

    def alter_tail!(lang)
      possible_indices = multiple_children_indices
      return false if possible_indices.empty?

      orig_words = @words.dup

      index = possible_indices.sample
      orig_child = @words[index + 1]

      done_looking = false
      new_child = false
      attempts = 0

      until done_looking
        @words = orig_words[0..index]
        lang.walk(@words.last[:word], self, :forward)
        new_child = @words[index + 1] != orig_child
        done_looking =  new_child || attempts > Constants::MAX_ALTERING_ATTEMPTS
        attempts += 1
      end

      if new_child #restore original words unless the change was a good one
        mark_index = index + 1 >= @words.length ? @words.length - 1 : index + 1
        @words[mark_index][:attr][:beginalteredtext] = true
        @words[-1][:attr][:endspan] = true
      else
        @words = orig_words
      end

      new_child
    end

    def alter_front!(lang)
      possible_indices = multiple_parents_indices
      return false if possible_indices.empty?

      orig_words = @words.dup

      index = possible_indices.sample
      orig_parent = index - 1
      done_looking = false
      new_parent = false
      attempts = 0

      until done_looking
        @words = orig_words[index..-1]
        start_length = @words.length
        lang.walk(@words.first[:word], self, :backward)
        end_length = @words.length
        new_parent = @words[index - 1] != orig_parent
        done_looking = new_parent || attempts > Constants::MAX_ALTERING_ATTEMPTS
        attempts += 1
      end

      if new_parent #restore original words unless the change was a good one
        @words[0][:attr][:beginalteredtext] = true
        @words[end_length - start_length][:attr][:endspan] = true
      else
        @words = orig_words
      end

      new_parent
    end

    def multiple_children_indices
      possible_indices = []
      @words[1..-1].each_with_index do |word_hash, i|
        possible_indices << (i + 1) if word_hash[:word].num_children > 1
      end
      possible_indices
    end

    def multiple_parents_indices
      possible_indices = []
      @words[0..-2].each_with_index do |word_hash, i|
        possible_indices << i if word_hash[:word].num_parents > 1
      end
      possible_indices
    end

    def self.line_from_prog_text(text, lang)
      line = Line.new
      attr = {}

      text.split(" ").each do |word|
        if word =~ /^[A-Z]+$/
          attr[word.downcase.to_sym] = true
        else
          mark_word = lang.fetch_word(word)
          raise "Word not found: '#{word}'" unless mark_word
          line.add_word_hash :word => lang.fetch_word(word), :attr => attr
          attr = {}
        end
      end

      line
    end
  end
end
