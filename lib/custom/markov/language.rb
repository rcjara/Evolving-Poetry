module Markov
  class Language
    attr_accessor :limit

    WORD_REGEX = /\S+\b|\.\.+|\:\S+|\.(?=\s)|\?(?=\s)|\!(?=\s)|\S/u

    def initialize(limit = Constants::MAX_NUM_CHARS)
      @limit = limit
      @words = {:__begin__ => Word.new(:__begin__)}
    end

    def ==(other)
      return false unless @limit == other.limit
      return false unless @words == other.instance_variable_get(:words)
      true
    end

    def words(all = false)
      return @words.keys if all
      @words.keys.select{|word| word.is_a?(String)}
    end

    def sorted_words
      @words.values.sort_by(&:count).reverse
    end

    def num_words
      words.length
    end

    def add_snippet(snippet)
      tokens = (snippet.to_s + " ").scan(WORD_REGEX)

      return self unless tokens && tokens.length > 0

      add_identifiers!(tokens)
      markov_words = [fetch(:__begin__)] + tokens.map { |t| fetch(t) }

      markov_words.each_cons(2) do |parent, child|
        parent.add_child(child)
        child.add_parent(parent)
      end

      self
    end

    def fetch(ident)
      @words[Word.identifier_for(ident)]
    end

    private

    def add_identifiers!(tokens)
      tokens.each do |token|
        ident = Word.identifier_for(token)
        if fetch(ident)
          fetch(ident).add_text(token)
        else
          @words[ident] = Word.new(token)
        end
      end
    end
  end
end
