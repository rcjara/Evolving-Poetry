class GraphGenerator
  attr_reader :lang

  def self.gen(file_name, lang)
    digraph do
      lang.words(true).each do |w_id|
        word = lang.fetch_word(w_id)
        next if word.nil?
        word.children.keys.each do |c_id|
          child = lang.fetch_word(c_id)
          next if child.nil?
          raise "No child: #{c_id}" if c_id.nil?
          raise "No word: #{w_id}" if c_id.nil?
          puts "edge #{word.identifier}, #{child.identifier}"
          edge word.identifier.to_s, child.identifier.to_s
        end
      end

      save file_name, 'png'
    end
  end

  def self.gen_simplified(file_name, lang, target = 10)
    words = build_simplified_words(lang, target)
    state = simplified_state(words)

    digraph do

      state.each_pair do |parent, children|
        children.each { |child| edge parent.to_s, child.to_s }
      end

      save file_name, 'png'
    end
  end

  def self.simplified_state(found_words)
    Hash.new.tap do |state|
      found_words.values.each do |mw|
        state[mw.identifier] =
          mw.children.keys.select { |child| found_words[child] }.sort
      end
    end
  end

  def self.build_simplified_words(lang, target)
    Hash.new.tap do |found_words|
      seed_word  = lang.fetch_word(:__begin__)
      okay_words = Hash.new(0)
      excluded_words = Set.new

      handle_found_word( seed_word, found_words, okay_words )

      keep_looking(lang, target, found_words, okay_words, excluded_words)
    end
  end

  def self.keep_looking(lang, target, found, okay, excluded)
    while found.length < target
      new_word = find_next_word(lang, found, okay, excluded)
      handle_found_word(new_word, found, okay)
    end

    if handle_danglers!(lang, found, okay, excluded)
      found
    else
      keep_looking(lang, target, found, okay, excluded)
    end
  end

  def self.handle_found_word(word, found_words, okay_words)
    found_words[word.identifier] = word
    word.children.keys.each do |child|
      okay_words[child] += 1
    end
  end

  def self.find_next_word(lang, found_words, okay_words, excluded_words)
    lang.sorted_words.each do |mw|
      ident = mw.identifier
      next if found_words[ident]
      next unless okay_words[ident] > 0
      next if excluded_words.include? ident

      return mw
    end

    found_words.keys.each { |fw| puts fw.to_s }
    raise "Fatal: No acceptable word found"
  end

  def self.dangler(found_words)
    found_words.values.find do |mw|
      dangling? found_words, mw
    end
  end

  def self.dangling?(found_words, mw)
    return false if mw.sentence_end?
    has_child = mw.children.keys.inject(false) { |m, child| m || found_words[child] }
    !has_child
  end

  def self.has_parent?(word, simple_state)
    all_children(simple_state).include? word
  end

  def self.all_children(simple_state)
    simple_state.values.inject(Set.new) {|s, c| s.merge c }
  end

  def self.find_ending(words)
    words.values.find {|w| w.sentence_end? }
  end

  def self.handle_danglers!(lang, found, okay, excluded)
    dangler = dangler(found)
    return true unless dangler

    ident = dangler.identifier
    found.delete(ident)
    dangler.children.each { |child| okay[child] -= 1 }
    excluded << ident
    false
  end
end
