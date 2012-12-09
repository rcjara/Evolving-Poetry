module Markov
  class Generator
    attr_reader :language

    COMMAND_SETS = { children: [:get_random_child, :sentence_end?],
                     parents:  [:get_random_parent, :sentence_begin?] }

    BadContinueLineResult = Object.new
    NoAvailableIndicesForAltering = Object.new

    def initialize(language)
      @language = language
    end

    def generate_line
      continue_line(language.fetch(:__begin__), Line.new)
    end

    def alter_line(line)
      indices = self.class.alterable_indices(line)
      return NoAvailableIndicesForAltering if indices == NoAvailableIndicesForAltering

      index = indices.sample
      word_displayers       = line.word_displayers[0..index]
      word_to_continue_from = line.word_at(index)
      word_to_avoid         = line.word_at(index + 1)

      old_line = Line.new(word_displayers)
      continue_line(word_to_continue_from, old_line, Set.new([word_to_avoid]))
                   .mark_as_altered!(index + 1, -1)
    end

    def self.alterable_indices(indices)
      indices.multiple_children_indices.reject { |i| i == 0 }.tap do |new_line|
        return NoAvailableIndicesForAltering if new_line.empty?
      end
    end

    private

    def continue_line(prev_word, prev_line, excluding = Set.new)
      return BadContinueLineResult if prev_line.num_chars > language.limit
      return prev_line             if prev_word.sentence_end?

      new_line  = BadContinueLineResult

      while new_line == BadContinueLineResult
        word = prev_word.get_random_child(excluding)
        excluding << word

        return BadContinueLineResult if word.nil?

        line = prev_line + WordDisplayer.new_with_rand_tags(word)
        new_line = continue_line(word, line)
      end

      new_line
    end
  end
end

