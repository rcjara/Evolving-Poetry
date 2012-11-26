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

      excluding = Set.new
      new_line  = BadContinueLineResult

      while new_line == BadContinueLineResult
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


#    def gen_line
#      line = Line.new
#      current_word = @words[:__begin__]
#
#      walk(current_word, line, :forward)
#    end
#
#    def walk(orig_word, line, direction = :forward, attempts = 0)
#      orig_length = line.length
#      current_word = orig_word
#
#      get_command, add_command, remove_command, terminate_command = if direction == :forward
#        [:get_random_child, :add_word, :remove_last_word, :sentence_end?]
#      else
#        [:get_random_parent, :push_word, :remove_first_word, :sentence_begin?]
#      end
#
#      while current_word = @words[current_word.send(get_command)]
#        line.send(add_command, current_word)
#        break if line.num_chars > @limit || current_word.send(terminate_command)
#      end
#
#      while line.num_chars > @limit
#        stop = false
#        until stop.nil? || stop
#          stop = line.send(remove_command)
#          stop = nil if line.length <= orig_length
#          #stop with a bad sentence (that is short enough) if attempts are too high
#          stop = true if attempts > Constants::MAX_WALK_ATTEMPTS && line.num_chars <= @limit
#        end
#        return walk(orig_word, line, direction, attempts + 1) if stop.nil?
#      end
#
#      line
#    end
#
#    def gen_poem(num_lines)
#      Poem.new( num_lines.times.collect{ gen_line } )
#    end

