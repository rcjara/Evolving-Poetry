module Markov
  class Evolver
    attr_reader :language

    BadContinueLineResult = :bad_continue_result
    NoAvailableIndicesForAltering = :no_indices_availabe

    def initialize(language)
      @language = language
    end

    def new_line
      continue_line([:__begin__], Line.new)
    end

    def new_poem(num_lines = nil)
      num_lines ||= (rand(3) + 1) + (rand(4) + 1)
      lines = num_lines.times.collect { new_line }
      Markov::Poem.new(lines)
    end

    ##########################
    # line evolution methods #
    ##########################

    def alter_line_tail(line)
      indices = alterable_indices(line, :forward)
      return NoAvailableIndicesForAltering if indices.empty?

      index = indices.sample
      to_avoid        = line.tokens[index + 1] || :__end__
      kept_portion    = Line.new(line.word_displayers[0..index])
      prev_tokens     = kept_portion.tokens

      new_line = continue_line(prev_tokens,
                               kept_portion,
                               :forward,
                               Set.new.add(to_avoid))

      return new_line if new_line == BadContinueLineResult

      if kept_portion.length == new_line.length
        new_line
      else
        new_line.mark_as_altered(index + 1, -1)
      end
    end

    def alter_line_front(line)
      indices = alterable_indices(line, :backward)
      return NoAvailableIndicesForAltering if indices.empty?

      index = indices.sample
      to_avoid        = index == 0 ? :__begin__ : line.tokens[index - 1]
      kept_portion    = Line.new(line.word_displayers[index..-1].reverse)
      prev_tokens     = kept_portion.tokens

      new_line = continue_line(prev_tokens,
                               kept_portion,
                               :backward,
                               Set.new.add(to_avoid))

      return new_line if new_line == BadContinueLineResult

      if kept_portion.length == new_line.length
        new_line.reverse
      else
        new_line.reverse.mark_as_altered(0, -(kept_portion.length + 1))
      end
    end

    def alterable_indices(line, direction)
      indices = line.tokens
                    .map { |t| language.multiple_children_for?([t], direction) }
                    .map.with_index { |bool, i| [bool, i] }
                    .select { |bool, _| bool }
                    .map { |_, i| i }

      if direction == :forward
        indices.reject { |i| i == 0 }
      elsif direction == :backward
        indices.reject { |i| i == line.tokens.length - 1 }
      end
    end

    ##########################
    # poem evolution methods #
    ##########################

    def mutate(poem)
      return add_line(poem) if poem.unaltered_indices.empty?

      possible_mutations = [ :add_line_to_poem,
                             :alter_a_tail,
                             :alter_a_front,
                             :delete_line_from_poem ]
      new_poem = nil
      until new_poem.is_a? Poem
        mutation = possible_mutations.sample
        possible_mutations.delete(mutation)
        new_poem = self.send(mutation, poem)
      end

      new_poem
    end

    def mate_poems(poem1, poem2)
      lines1 = poem1.half_lines
      lines2 = poem2.half_lines
      prob = lines1.length
      out_of = prob + lines2.length
      child_lines  = []
      which_parent = []

      #randomly start stacking the lines on top of each other
      while lines1.length > 0 && lines2.length > 0
        if rand(out_of) < prob
          child_lines  << lines1.slice!(0)
          which_parent << true
        else
          child_lines  << lines2.slice!(0)
          which_parent << false
        end
      end
      #add any lines left to the poem
      child_lines  += lines1 + lines2
      which_parent += ([true] * lines1.length) + ([false] * lines2.length)

      #mark which lines came from which parent
      marked_lines = child_lines.zip(which_parent)
                                .collect do |line, from_first_parent|
        if from_first_parent
          line.mark_as_from_first_parent
        else
          line.mark_as_from_second_parent
        end
      end

      Poem.new(marked_lines)
    end

    def add_line_to_poem(poem)
      i = rand(poem.length + 1)
      poem.insert_line_at(new_line.mark_as_new, i)
    end

    def delete_line_from_poem(poem)
      i = poem.unaltered_indices.sample

      return NoAvailableIndicesForAltering if i.nil?

      deleted_line = poem.lines[i].mark_as_deleted
      poem.replace_line_at(deleted_line, i)
    end

    def alter_a_tail(poem)
      indices = alterable_line_indices(poem, :forward)
      return poem if indices.empty?

      i = indices.sample
      old_line = poem.lines[i]
      new_line = alter_line_tail(old_line)

      poem.replace_line_at(new_line, i)
    end

    def alter_a_front(poem)
      indices = alterable_line_indices(poem, :backward)
      return poem if indices.empty?

      i = indices.sample
      old_line = poem.lines[i]
      new_line = alter_line_front(old_line)

      poem.replace_line_at(new_line, i)
    end

    private

    def alterable_line_indices(poem, direction)
      poem.unaltered_indices
          .map    { |i| [poem.lines[i], i] }
          .reject { |line, _| alterable_indices(line, direction).empty? }
          .map    { |_, i| i }
    end

    def continue_line(prev_tokens, prev_line,
                      set = :forward, excluding = Set.new)
      return BadContinueLineResult if prev_line.num_chars > language.limit
      return prev_line             if criteria_met?(prev_tokens, set)

      new_line  = BadContinueLineResult

      tokens = trim_tokens(prev_tokens)
      while new_line == BadContinueLineResult
        token = language.fetch_random_child_for(tokens, set, excluding)

        return BadContinueLineResult if token.nil?

        excluding << token
        word = language.fetch(token)

        cur_line = prev_line + WordDisplayer.new_with_rand_tags(word)
        new_tokens = prev_tokens + [token]
        new_line = continue_line(new_tokens, cur_line, set)
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

