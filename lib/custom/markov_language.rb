class MarkovLanguage
  attr_accessor :limit

  WORD_REGEX = /\S+\b|\.\.+|\:\S+|\.(?=\s)|\?(?=\s)|\!(?=\s)|\S/u
  
  def initialize(limit = 120)
    @limit = limit
    @words = {:begin => MarkovWord.new(:begin, nil)}
  end
  
  def ==(other)
    return false unless @limit == other.limit
    return false unless @words == other.word_hash
    true
  end
  
  def dup
    other = MarkovLanguage.new(@limit)
    keys = @words.keys
    keys.each do |key|
      other.word_hash[key] = @words[key].dup
    end
    other
  end
  
  def words
    @words.keys.select{|word| word.is_a?(String)}
  end
  
  def num_words
    @words.length - 1
  end
  
  def add_snippet(snippet)
    pieces = (snippet.to_s + " ").scan(WORD_REGEX)
    
    return unless pieces && pieces.length > 0
    
    handle_word_pair(:begin, pieces[0])
    
    pieces.each_cons(2) do |word_pair|
      handle_word_pair(word_pair[0], word_pair[1])
    end

    @words[pieces[-1].downcase].add_child(nil)
  end
  
  def gen_line
    line = MarkovLine.new
    current_word = @words[:begin]
    
    while current_word = @words[current_word.get_random_child]
      line.add_word(current_word)
      break if line.num_chars > @limit + 1
    end
    
    while line.num_chars > @limit + 1
      stop = false
      until stop.nil? || stop
        stop = line.remove_last_word
      end

      return gen_line if stop.nil?
    end

    line
  end

  def gen_poem(num_lines)
    MarkovPoem.new( num_lines.times.collect{ gen_line } )
  end
  
  def fetch_word(ident)
    return nil unless ident
    if ident.is_a?(Symbol)
      @words[ident]
    else
      @words[ident.downcase]
    end
  end

  private
  
  def handle_word_pair(first_word, second_word)
    return unless first_word && second_word
    first_markov_word = fetch_word(first_word)
    second_markov_word = fetch_word(second_word)
    raise "Warning: This word really should exist by now" unless first_markov_word
    first_markov_word.add_child(second_word)
    
    if second_markov_word
      second_markov_word.add_parent(first_word, second_word)
    else 
      @words[second_word.downcase] = MarkovWord.new(second_word, first_word)
    end
  end
  
  protected
  
  attr_writer :words
  
  def word_hash
    @words
  end
  
end
