class MarkovLine
  attr_reader :words

  def initialize
    @words = []
    @num_chars = 0
  end

  def num_chars
    @num_chars == 0 ? 0 : @num_chars - 1
  end

  def add_word(word)
    attr = {}
    attr[:shout] = word.should_shout?

    @words << {:word => word, :attr => attr}
    @num_chars += word.display.length
  end

  def add_word_hash(hash)
    @words << hash
  end

  #Removed the last word hash from @words
  #Return whether the remaining word is a valid sentence end
  def remove_last_word
    return nil unless @words.length > 1
    removed = @words.pop
    @num_chars -= removed[:word].display(removed[:attr]).length

    new_end_word = @words.last[:word]
    new_end_word.terminates? || new_end_word.sentence_end?
  end

  def display(sentence_begin = true)
    @words.collect do |hash| 
      w = hash[:word]
      a = hash[:attr]

      this_begin = sentence_begin  
      sentence_begin = w.sentence_end?

      w.display(a, this_begin) 
    end.join.strip
  end

  def to_prog_text
    @words.collect do |h| 
      key_words = ""
      h[:attr].each_pair do |k, val|
        key_words << k.to_s.upcase + " " if val
      end

      key_words + h[:word].identifier
    end.join(" ")
  end

  def self.from_prog_text(text, lang)
    text.split(/\sBREAK\s/).collect { |t| line_from_prog_text(t, lang) }
  end

  def self.line_from_prog_text(text, lang)
    line = MarkovLine.new
    attr = {}

    text.split(" ").each do |word|
      if word =~ /^[A-Z]+$/
        attr[word.downcase.to_sym] = true
      else
        line.add_word_hash :word => lang.fetch_word(word), :attr => attr 
        attr = {}
      end
    end

    line
  end
end
