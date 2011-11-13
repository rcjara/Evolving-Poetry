class GraphGenerator
  attr_reader :lang

  def initialize(lang)
    @lang = lang
  end

  def gen_graph(file_name, lang = @lang)
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
end
