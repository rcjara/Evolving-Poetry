module Markov
  class Generator
    attr_reader :language

    COMMAND_SETS = { children: [:get_random_child, :sentence_end?],
                     parents:  [:get_random_parent, :sentence_begin?] }

    BadContinueLineResult = Class.new

    def initialize(language)
      @language = language
    end

    def generate_line
      continue_line(language.fetch(:__begin__), Line.new)
    end

    def continue_line(prev_word, prev_line)
      return BadContinueLineResult if prev_line.num_chars > language.limit
      return prev_line             if prev_word.sentence_end?

      excluding = []
      new_line  = BadContinueLineResult

      while new_line == BadContinueLineResult
        #puts "excluding: " + excluding.map(&:identifier).join(' ')
        word = prev_word.get_random_child(excluding)
        excluding << word

        return BadContinueLineResult if word.nil?

        line = prev_line + WordDisplayer.new_with_rand_tags(word)
        new_line = continue_line(word, line)
      end

      raise "Why is new_line nil?" if new_line.nil?
      new_line
    end
  end
end
