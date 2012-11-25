module Markov
  class Generator
    attr_reader :language

    COMMAND_SETS = { children: [:get_random_child, :sentence_end?],
                     parents:  [:get_random_parent, :sentence_begin?] }


    def initialize(language)
      @language = language
    end

    def generate_line
      start_word = language.fetch_word(:__begin__)
      generate_word_array(start_word)
        .collect { |word| WordDisplayer.new_with_rand_tags(word) }
        .inject(Line.new, :+)
    end

    def generate_word_array(current_word,
                            command_set = :children)
      next_word_cmd, end_condition = COMMAND_SETS[command_set]

      [current_word].tap do |array|
        until current_word.send(end_condition)
          next_identifier = current_word.send(next_word_cmd)
          current_word    = language.fetch_word(next_identifier)
          array << current_word
        end
      end
    end

  end
end
