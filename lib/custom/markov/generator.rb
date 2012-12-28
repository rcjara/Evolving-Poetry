module Markov
  class Generator
    attr_reader :language

    BadContinueLineResult = Object.new.tap do |obj|
      obj.define_singleton_method(:inspect) do
        '<BadContinueLineResult>'
      end
    end

    NoAvailableIndicesForAltering = Object.new.tap do |obj|
      obj.define_singleton_method(:inspect) do
        '<NoAvailableIndicesForAltering>'
      end
    end

    def initialize(language)
      @language = language
    end

    def generate_line
      continue_line([:__begin__], Line.new)
    end

    def generate_poem(num_lines = nil)
      num_lines ||= (rand(3) + 1) + (rand(4) + 1)
      lines = num_lines.times.collect { generate_line }
      Poem.new(lines)
    end

    def alter_line(line)
      indices = alterable_indices(line, :forward)
      return NoAvailableIndicesForAltering if indices.empty?

      index = indices.sample
      to_avoid        = line.tokens[index + 1]
      kept_line       = Line.new(line.word_displayers[0..index])
      prev_tokens     = kept_line.tokens

      continue_line(prev_tokens, kept_line, :forward, Set.new.add(to_avoid))
                   .mark_as_altered(index + 1, -1)
    end

    def alter_beginning(line)
      indices = alterable_indices(line, :backward)
      return NoAvailableIndicesForAltering if indices.empty?

      index = indices.sample
      to_avoid        = line.tokens[index - 1]
      kept_line       = Line.new(line.word_displayers[index..-1].reverse)
      prev_tokens     = kept_line.tokens

      continue_line(prev_tokens, kept_line, :backward, Set.new.add(to_avoid))
                   .reverse
                   .mark_as_altered(0, -(index +1))
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
      return prev_line             if criteria_met?(prev_tokens, set)

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

    def criteria_met?(prev_tokens, set)
      word = language.fetch(prev_tokens.last)
      (set == :forward && word.end?) || (set == :backward && word.begin?)
    end
  end
end

