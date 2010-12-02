#require File.expand_path(File.dirname(__FILE__) + '/MarkovWord')

class MarkovLanguage
  attr_accessor :limit
  
  def initialize(limit = 140)
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
    pieces = (snippet + " ").scan(/\S+\b|\.\.+|\:\S+|\.\s|\?\s|\!\s|\S/u)
    
    return unless pieces
    return unless pieces.length > 0
    
    handle_word_pair(:begin, pieces[0])
    
    pieces.each_cons(2) do |word_pair|
      handle_word_pair(word_pair[0], word_pair[1])
    end

    @words[pieces[-1].downcase].add_child(nil)
  end
  
  def gen_snippet
    sentence = ""
    sentence_array = []
    current_word = @words[:begin]
    new_sentence = true
    
    while current_word = @words[current_word.get_random_child]
      sentence_array << current_word
      sentence << current_word.display(new_sentence)
      new_sentence = current_word.sentence_end?
      break if sentence.length > @limit + 1
    end
    
    while sentence.length > @limit + 1
      end_point = -2
      while sentence_array[end_point].terminates? != true && -end_point >= sentence_array.length
        end_point -= 1
      end
      return gen_snippet if -end_point >= sentence_array.length
      sentence_array = sentence_array[0..end_point]
      sentence = sentence_array.collect{ |word| word.display }.join
    end
    
    sentence.strip
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
