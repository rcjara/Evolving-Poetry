class GraphGenerator
  attr_reader :lang

  def initialize(lang)
    @lang = lang
  end

  def gen(file_name, lang = @lang)
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

  def gen_simplified(file_name, limit = 20, lang = @lang)
    sorted_hash  = lang.sorted_words[0...limit]
    sorted_words = sorted_hash.collect{ |h| h[:word].to_s }

    digraph do
      sorted_hash.each do |h|
        m_word = lang.fetch_word(h[:word])
        word   = h[:word].to_s
        m_word.sorted_children[0...limit].each do |h2|
          child = h2[:word].to_s
          if sorted_words.include? child
            edge word, child
          end
        end
      end

      save file_name, 'png'
    end
  end
end
