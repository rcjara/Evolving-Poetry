module Markov
  class Word
    attr_reader :identifier, :count, :parents_count, :children_count, :shout_count, :children

    PUNCTUATION_REGEX = /[\.\,\:\;\!\?]/
    SENTENCE_END_REGEX = /^\.|^\?|^\!/

    def initialize(ident, parent, sentence_begin = false)
      @identifier = Word.downcase(ident)
      @punctuation = Word.is_punctuation_test?(ident)
      @sentence_end = Word.is_sentence_end_test?(ident)
      @begin = ident == :__begin__

      @count, @parents_count, @children_count, @shout_count = 0, 0, 0, 0
      @parents = Hash.new(0)
      @children = Hash.new(0)

      @proper = true
      @shoutable = false
      @speakable = false
      @terminates = false

      add_parent(parent, ident, sentence_begin)
    end

    def dup
      other = Word.new("","")
      other.parents = @parents.dup
      other.children = @children.dup
      other.proper = @proper
      other.shoutable = @shoutable
      other.speakable = @speakable
      other.terminates = @terminates
      other.punctuation = @punctuation
      other.sentence_begin = @sentence_begin
      other.begin = @begin
      other.sentence_end = @sentence_end
      other.identifier = @identifier.is_a?(String) ? @identifier.dup : @identifier
      other.count = @count
      other.parents_count = @parents_count
      other.children_count = @children_count
      other.shout_count = @shout_count
      other
    end

    def ==(other)
      return false unless @identifier == other.identifier
      return false unless @count == other.count
      return false unless @shout_count == other.shout_count
      return false unless speak_count == other.speak_count
      return false unless @proper == other.proper?
      return false unless @shoutable == other.shoutable?
      return false unless @speakable == other.speakable?
      return false unless @terminates == other.terminates?
      return false unless @children == other.children
      return false unless @parents == other.parents
      return false unless @sentence_begin == other.sentence_begin?
      return false unless @begin == other.is_begin?
      return false unless @parents == other.parents

      true
    end

    def speak_count
      @count - @shout_count
    end

    def num_parents
      @parents.length
    end

    def num_children
      @children.length
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
        parent = Word.downcase(parent)
        @parents_count += 1
        @parents[parent] = @parents[parent] + 1
      end
    end

    def add_child(child = nil)
      if child.nil?
        @terminates = true
      else
        child = Word.downcase(child)
      end
      @children_count += 1
      @children[child] = @children[child] + 1
    end

    def child_can_begin?
      @sentence_end || @begin
    end

    def get_random_child
      get_random_relative(@children, @children_count)
    end

    def get_random_parent
      get_random_relative(@parents, @parents_count)
    end

    def display(options = {}, first = false)
      return "" if is_begin?

      display_word = @identifier.dup
      display_word.capitalize! if first | proper?
      display_word = " " + display_word unless punctuation?
      display_word.upcase! if options[:shout]

      display_word.insert(0, %{<span class="new-text">})           if options[:beginnewtext]
      display_word.insert(0, %{<span class="altered-text">})       if options[:beginalteredtext]
      display_word.insert(0, %{<span class="deleted-text">})       if options[:begindeleted]
      display_word.insert(0, %{<span class="from-first-parent">})  if options[:fromfirstparent]
      display_word.insert(0, %{<span class="from-second-parent">}) if options[:fromsecondparent]

      display_word.insert(-1, %{</span>}) if options[:endspan]
      display_word.insert(-1, %{</span>}) if options[:enddeleted]

      display_word
    end

    def should_shout?
      rand(count) < shout_count
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

      def speakable_test?(word)
        !Word.shoutable_test?(word)
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

    def sorted_children
      sorted_hash(@children)
    end

    def sorted_parents
      sorted_hash(@parents)
    end

    private

    def get_random_relative(relatives, count)
      index = rand(count)
      keys = relatives.keys
      keys.inject(0) do |running_index, key|
        running_index += relatives[key]
        return key if running_index > index
        running_index
      end
    end

    def sorted_hash(hash)
      pairs = hash.each_pair.collect{|w, n| { word: w, occurances: n } }
      pairs.sort{|a, b| b[:occurances] <=> a[:occurances] }
    end

    protected

    attr_reader :parents
    attr_writer :parents, :children, :proper, :shoutable, :speakable,
      :terminates, :punctuation, :sentence_end, :identifier, :count,
      :parents_count, :children_count, :shout_count, :begin, :sentence_begin
  end
end
