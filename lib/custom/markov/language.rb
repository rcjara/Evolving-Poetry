module Markov
  class Language
    class InvalidSetException < Exception
    end
    class InvalidPrecedingTokensException < Exception
    end

    attr_reader :limit, :highest_order, :counts

    WORD_REGEX = /\S+\b|\.\.+|\:\S+|\.(?=\s)|\?(?=\s)|\!(?=\s)|\S/u

    def initialize(highest_order = 1, limit = Constants::MAX_NUM_CHARS)
      @limit = limit
      @highest_order = highest_order

      @words  = {}
      @counts = {
                  :forward  => {},
                  :backward => {}
                }
    end

    def tokens(all = false)
      return words.keys if all
      words.keys.select{|word| word.is_a?(String)}
    end

    def sorted_words
      words.values.sort_by(&:count).reverse
    end

    def num_words
      tokens.length
    end

    def add_snippet(snippet)
      split_into_sentences(snippet).each do |sentence|
        add_sentence(sentence)
      end

      self
    end

    def fetch(ident)
      words[Word.identifier_for(ident)]
    end

    def multiple_children_for?(*args)
      counter_for(*args).length > 1
    end

    def fetch_random_child_for(preceding_tokens, set = :forward, excluding = Set.new)
      begin
        counter_for(preceding_tokens, set).get_random_item(excluding)
      rescue InvalidPrecedingTokensException
        nil
      end
    end

    def split_into_sentences(text)
      tokens = (text + " ").scan(WORD_REGEX)

      break_points = tokens.zip(0...(tokens.length))
                           .select { |token, _| token =~ Word::SENTENCE_END_REGEX }
                           .map { |_, i| i }
      ([-1] + break_points + [-1]).each_cons(2).map do |start, finish|
        tokens[(start + 1)..finish]
      end.reject(&:empty?)
    end

    private

    attr_reader :words

    def counter_for(preceding_tokens, set = :forward)
      counts_hash = counts[set]
      raise InvalidSetException.new unless counts_hash

      counts_hash[preceding_tokens].tap do |counter|
        raise InvalidPrecedingTokensException if counter.nil?
      end
    end

    def add_sentence(tokens)
      return unless tokens.length > 0

      identifiers = add_identifiers!([:__begin__] + tokens + [:__end__])

      (2..(highest_order + 1)).each do |order|
        identifiers.each_cons(order) { |tokens| add_counts(tokens) }
      end
    end

    def add_identifiers!(tokens)
      tokens.collect do |token|
        Word.identifier_for(token).tap do |ident|
          if fetch(ident)
            fetch(ident).add_text(token)
          else
            words[ident] = Word.new(token)
          end
        end
      end
    end

    def add_counts(tokens)
      add_counts_to_set :forward,  tokens
      add_counts_to_set :backward, tokens.reverse
    end

    def add_counts_to_set(set, tokens)
      *preceding, item = tokens

      counts[set][preceding] = Counter.new unless counts[set][preceding]
      counts[set][preceding].add_item(item)
    end
  end
end
