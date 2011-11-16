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

    digraph do

      words.values.each do |mw|
        mw.children.keys.each do |child|
          if words[child]
            parent = mw.identifier.to_s
            puts "#{parent}, #{child.to_s}"
            edge parent, child.to_s
          end
        end
      end

      save file_name, 'png'

    end
  end

  def self.build_simplified_words(lang, target)
    Hash.new.tap do |found_words|
      seed_word   = lang.fetch_word(:__begin__)

      okay_words  = {}

      handle_found_word( seed_word, found_words, okay_words )

      while found_words.length < target
        new_word = find_next_word(lang, found_words, okay_words)
        handle_found_word(new_word, found_words, okay_words)
      end
    end
  end

  def self.handle_found_word(word, found_words, okay_words)
    found_words[word.identifier] = word
    word.children.keys.each do |child|
      okay_words[child] = true
    end
  end

  def self.find_next_word(lang, found_words, okay_words)
    lang.sorted_words.each do |mw|
      next if found_words[mw.identifier]
      next unless okay_words[mw.identifier]

      return mw
    end

    found_words.keys.each { |fw| puts fw.to_s }
    raise "Fatal: No acceptable word found"
  end
end
