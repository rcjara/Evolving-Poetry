class MarkovLanguage
  attr_accessor :limit

  WORD_REGEX = /\S+\b|\.\.+|\:\S+|\.(?=\s)|\?(?=\s)|\!(?=\s)|\S/u
  
  def initialize(limit = Constants::MAX_NUM_CHARS)
    @limit = limit
    @words = {:begin => MarkovWord.new(:begin, nil, false)}
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
    
    walk(current_word, line, :forward)
  end

  def walk(orig_word, line, direction = :forward, attempts = 0)
    orig_length = line.length
    current_word = orig_word

    get_command, add_command, remove_command = if direction == :forward
      [:get_random_child, :add_word, :remove_last_word]
    else
      [:get_random_parent, :push_word, :remove_first_word]
    end

    while current_word = @words[current_word.send(get_command)]
      line.send(add_command, current_word)
      break if line.num_chars > @limit
    end
    
    while line.num_chars > @limit
      stop = false
      until stop.nil? || stop
        stop = line.send(remove_command)
        stop = nil if line.length <= orig_length
        #stop with a bad sentence (that is short enough) if attempts are too high
        stop = true if attempts > Constants::MAX_WALK_ATTEMPTS && line.num_chars <= @limit
      end
      return walk(orig_word, line, direction, attempts + 1) if stop.nil?
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

    sentence_begin = first_markov_word.child_can_begin?
    
    if second_markov_word
      second_markov_word.add_parent(first_word, second_word, sentence_begin)
    else 
      @words[second_word.downcase] = MarkovWord.new(second_word, first_word, sentence_begin)
    end
  end
  
  protected
  
  attr_writer :words
  
  def word_hash
    @words
  end
  
end
