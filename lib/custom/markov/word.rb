module Markov
  class Word
    attr_reader :identifier, :count, :shout_count, :parents, :children

    PUNCTUATION_REGEX  = /[\.\,\:\;\!\?]/
    SENTENCE_END_REGEX = /^\.|^\?|^\!/

    def initialize(ident, parent, sentence_begin = false)
      @identifier    = Word.downcase(ident)
      @punctuation   = Word.is_punctuation_test?(ident)
      @sentence_end  = Word.is_sentence_end_test?(ident)
      @begin         = ident == :__begin__

      @count = @shout_count = 0
      @parents    = Counter.new
      @children   = Counter.new

      @proper     = true
      @shoutable  = false
      @speakable  = false
      @terminates = false

      add_parent(parent, ident, sentence_begin)
    end

    def ==(other)
      instance_variables.each do |var|
        return false unless instance_variable_get(var) ==
                            other.instance_variable_get(var)
      end

      true
    end

    def speak_count
      count - shout_count
    end

    def add_identifier(ident)
      @count += 1
      @proper &&= Word.proper_test? ident

      if Word.shoutable_test?(ident)
        @shoutable = true
        @shout_count += 1
      else
        @speakable = true
      end
    end

    def add_parent(parent, ident, sent_begin)
      @sentence_begin ||= sent_begin
      add_identifier(ident)
      unless parent == :__begin__
        parents.add_item( Word.downcase(parent) )
      end
    end

    def add_child(child = nil)
      if child.nil?
        @terminates = true
      else
        children.add_item( Word.downcase(child) )
      end
    end

    def child_can_begin?
      @sentence_end || @begin
    end

    def get_random_child
      children.get_random_item
    end

    def get_random_parent
      parents.get_random_item
    end

    def shout_prob
       shout_count.to_f / count
    end

    def has_multiple_parents?
      parents.length > 1
    end

    def has_multiple_children?
      children.length > 1
    end

    class << self
      def downcase(ident)
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

      def is_sentence_begin_test?(prev_word)
        prev_word.is_begin? || Word.is_sentence_end_test?(prev_word)
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
      @shoutable
    end

    def speakable?
      @speakable
    end

    def terminates?
      @terminates
    end

    def punctuation?
      @punctuation
    end

    def sentence_end?
      @sentence_end
    end

    def is_begin?
      @begin
    end

    def sentence_begin?
      @sentence_begin
    end

  end
end
