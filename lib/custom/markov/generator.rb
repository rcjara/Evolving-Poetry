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
      continue_line([:__begin__], Line.new)
    end

    def alter_line(line)
      indices = alterable_indices(line, :forward)
      return NoAvailableIndicesForAltering if indices.empty?

      index = indices.sample
      word_displayers  = line.word_displayers[0..index]
      to_continue_from = line.tokens[index]
      to_avoid         = line.tokens[index + 1]

      old_line = Line.new(word_displayers)
      continue_line([to_continue_from], old_line, :forward, Set.new.add(to_avoid))
                   .mark_as_altered!(index + 1, -1)
    end

    def alterable_indices(line, direction)
      indices = line.tokens.map { |t| language.multiple_children_for?([t], direction) }
                           .map.with_index { |bool, i| [bool, i] }
                           .select { |bool, _| bool }
                           .map { |_, i| i }

      if direction == :forward
        indices.reject { |i| i == 0 }
      elsif direction == :backward
        indices.reject { |i| i == line.tokens.length - 1 }
      end
    end

    private

    def continue_line(prev_tokens, prev_line, set = :forward, excluding = Set.new)
      return BadContinueLineResult if prev_line.num_chars > language.limit
      return prev_line             if criteria_met?(prev_tokens)

      new_line  = BadContinueLineResult

      tokens = trim_tokens(prev_tokens)
      while new_line == BadContinueLineResult
        token = language.fetch_random_child_for(tokens, set, excluding)

        return BadContinueLineResult if token.nil?

        excluding << token
        word = language.fetch(token)

        new_line = prev_line + WordDisplayer.new_with_rand_tags(word)
        new_tokens = prev_tokens + [token]
        new_line = continue_line(new_tokens, new_line, set)
      end

      new_line
    end

    def trim_tokens(tokens)
      if tokens.length > language.highest_order
        tokens.drop(tokens.length - language.highest_order)
      else
        tokens
      end
    end

    def criteria_met?(prev_tokens)
      word = language.fetch(prev_tokens.last)
      prev_tokens.length > 1 && word.sentence_end?
    end
  end
end

