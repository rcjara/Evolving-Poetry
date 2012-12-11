module Markov
  class MarkEmptyLineException < Exception
  end

  TAG_REGEX = /^[A-Z]+(-[A-Z]+)*$/

  class Line
    attr_reader :word_displayers

    def initialize(word_displayers = [])
      @word_displayers = word_displayers.collect { |wd| wd.dup }
    end

    def word_at(i)
      word_displayers[i].word
    end

    def tokens
      word_displayers.map(&:word)
                     .map(&:identifier)
    end

    def tags_at_index(i)
      word_displayers[i].tags
    end

    def +(word_displayer)
      self.class.new(@word_displayers + [word_displayer])
    end

    def <<(word_displayer)
      word_displayers << word_displayer
    end

    def num_chars
      raw_chars = word_displayers.map(&:num_chars).inject(0, :+)
      raw_chars > 0 ? raw_chars - 1 : raw_chars
    end

    def length
      word_displayers.length
    end

    def deleted?
      return false if word_displayers.empty?
      word_displayers.first.has_tag?(:begindeleted) &&
              word_displayers.last.has_tag?(:enddeleted)
    end

    def mark!(begin_tag, end_tag = :endspan)
      mark_indices!(begin_tag, end_tag, 0, -1)
    end

    def mark_as_new!
      mark!(:beginnewtext)
    end

    def mark_as_deleted!
      mark!(:begindeleted, :enddeleted)
    end

    def mark_as_altered!(start_i, end_i)
      mark_indices!(:beginalteredtext, :endspan, start_i, end_i)
    end

    def mark_as_from_first_parent!
      mark!(:fromfirstparent)
    end

    def mark_as_from_second_parent!
      mark!(:fromsecondparent)
    end

    def empty?
      word_displayers.empty?
    end

    def unwrapped_sentence
      ends = word_displayers.collect(&:sentence_end?)
      beginnings = [true] + ends[0...-1]
      word_displayers.zip(beginnings)
                     .collect { |w, b| w.display(b) }
                     .join
                     .strip
    end

    def display
      "<p>" + unwrapped_sentence + "</p>"
    end

    def to_prog_text
      word_displayers.collect(&:to_prog_text).join(' ')
    end

    def self.new_from_prog_text(text, lang)
      Line.new.tap do |line|
        tags = []

        text.split(" ").each do |word|
          if word =~ TAG_REGEX
            tags << word.downcase.to_sym
          else
            markov_word = lang.fetch(word)
            raise "Word not found: '#{word}'" unless markov_word
            line << WordDisplayer.new(markov_word, tags)
            tags = []
          end
        end
      end
    end

    private

    def mark_indices!(first_tag, second_tag, first_i, second_i)
      raise MarkEmptyLineException.new if empty?
      word_displayers[first_i].add_tag  first_tag
      word_displayers[second_i].add_tag second_tag

      self

    end
  end
end
