module Markov
  class Word
    attr_reader :identifier, :count, :shout_count, :parents, :children

    PUNCTUATION_REGEX  = /^[\.\,\:\;\!\?]$/
    SENTENCE_END_REGEX = /^[\.\!\?]$/

    def initialize(ident)
      @identifier     = Word.identifier_for(ident)
      @punctuation    = Word.is_punctuation_test?(ident)
      @sentence_end   = Word.is_sentence_end_test?(ident)
      @begin          = ident == :__begin__
      @end            = ident == :__end__

      @count = @shout_count = 0

      @proper     = true

      add_text(ident)
    end

    def ==(other)
      instance_variables.each do |var|
        return false unless instance_variable_get(var) ==
                            other.instance_variable_get(var)
      end

      true
    end

    def inspect
      %|<Markov::Word "#{identifier}">|
    end

    def speak_count
      count - shout_count
    end

    def add_text(ident)
      @count += 1
      @shout_count += 1 if Word.shoutable_test?(ident)
      @proper &&= Word.proper_test? ident

      self
    end

    class << self
      def identifier_for(ident)
        if ident && !ident.is_a?(Symbol)
          ident.downcase
        else
          ident
        end
      end

      def proper_test?(word)
        (word == word.capitalize) || Word.shoutable_test?(word)
      end

      def shoutable_test?(word)
        word.is_a?(String) && word.strip.length > 1 && word == word.upcase
      end

      def is_sentence_end_test?(word)
        word = word.to_s
        return false unless word =~ SENTENCE_END_REGEX
        return false if word =~ /\.\.+/  #this is for ellipses, e.g. "...."
        true
      end

      def is_punctuation_test?(word)
        word = word.to_s
        return false unless word.scan(PUNCTUATION_REGEX).length > 0
        return false if word.scan(/\:\S+/).length > 0    #this is for smileys
        true
      end
    end

    def proper?
      @proper
    end

    def shoutable?
      shout_count > 0
    end

    def speakable?
      shout_count < count
    end

    def punctuation?
      @punctuation
    end

    def sentence_end?
      @sentence_end
    end

    def begin?
      @begin
    end

    def end?
      @end
    end
  end
end
