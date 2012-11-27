module Markov
  class MarkEmptyLineException < Exception
  end

  class Line
    attr_reader :words

    def initialize(words = [])
      @words = words
    end

    def +(word_displayer)
      self.class.new(@words + [word_displayer])
    end

    def num_chars
      raw_chars = words.map(&:num_chars).inject(0, :+)
      raw_chars > 0 ? raw_chars - 1 : raw_chars
    end

    def add_word(word, tags = [])
      displayer = WordDisplayer.new(word, tags)
      @words.push displayer
    end

    def push_word(word, tags = [])
      displayer = WordDisplayer.new(word, tags)
      @words.unshift displayer
    end

    def length
      words.length
    end

    def deleted?
      return false if words.empty?
      words.first.has_tag?(:begindeleted) && words.last.has_tag?(:enddeleted)
    end

    def mark!(begin_tag, end_tag = :endspan)
      raise MarkEmptyLineException.new if words.empty?
      words.first.add_tag begin_tag
      words.last.add_tag end_tag

      self
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
      words.empty?
    end

    #Removed the last WordDisplayer from words
    #Return whether the remaining word is a valid sentence end
    def remove_last_word
      return nil unless words.length > 1
      words.pop
      words.last.word.sentence_end?
    end

    #Removed the first word hash from words
    #Return whether the remaining word is a valid sentence end
    def remove_first_word
      return nil unless words.length > 1
      words.shift
      new_first_word = words.first.word
      new_first_word.sentence_begin?
    end

    def unwrapped_sentence(sentence_begin = true)
      ends = words.collect(&:sentence_end?)
      beginnings = [sentence_begin] + ends[0...-1]
      words.zip(beginnings)
           .collect { |w, b| w.display(b) }
           .join
           .strip
    end

    def display(sentence_begin = true)
      "<p>" + unwrapped_sentence(sentence_begin) + "</p>"
    end

    def to_prog_text
      words.collect(&:to_prog_text).join(' ')
    end

    def alter_tail!(lang)
      possible_indices = multiple_children_indices
      return false if possible_indices.empty?

      orig_words = words.dup

      index = possible_indices.sample
      orig_child = words[index + 1]

      done_looking = false
      new_child = false
      attempts = 0

      until done_looking
        words = orig_words[0..index]
        lang.walk(words.last.word, self, :forward)
        new_child = words[index + 1] != orig_child
        done_looking =  new_child || attempts > Constants::MAX_ALTERING_ATTEMPTS
        attempts += 1
      end

      if new_child #restore original words unless the change was a good one
        mark_index = index + 1 >= words.length ? words.length - 1 : index + 1
        words[mark_index].add_tag :beginalteredtext
        words.last.add_tag :endspan
      else
        words = orig_words
      end

      new_child
    end

    def alter_front!(lang)
      possible_indices = multiple_parents_indices
      return false if possible_indices.empty?

      orig_words = words.dup

      index = possible_indices.sample
      orig_parent = index - 1
      done_looking = false
      new_parent = false
      attempts = 0

      until done_looking
        words = orig_words[index..-1]
        start_length = words.length
        lang.walk(words.first.word, self, :backward)
        end_length = words.length
        new_parent = words[index - 1] != orig_parent
        done_looking = new_parent || attempts > Constants::MAX_ALTERING_ATTEMPTS
        attempts += 1
      end

      if new_parent #restore original words unless the change was a good one
        words.first.add_tag :beginalteredtext
        words[end_length - start_length].add_tag :endspan
      else
        words = orig_words
      end

      new_parent
    end

    def multiple_children_indices
      possible_indices = []
      words[1..-1].each_with_index do |word, i|
        possible_indices << (i + 1) if word.has_multiple_children?
      end
      possible_indices
    end

    def multiple_parents_indices
      possible_indices = []
      words[0...-1].each_with_index do |word, i|
        possible_indices << i if word.has_multiple_parents?
      end
      possible_indices
    end

    def self.new_from_prog_text(text, lang)
      line = Line.new
      tags = []

      text.split(" ").each do |word|
        if word =~ /^[A-Z]+$/
          tags << word.downcase.to_sym
        else
          mark_word = lang.fetch(word)
          raise "Word not found: '#{word}'" unless mark_word
          line.add_word lang.fetch(word), tags
          tags = []
        end
      end

      line
    end
  end
end
