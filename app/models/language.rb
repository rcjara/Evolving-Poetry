class Language < ActiveRecord::Base
  attr_accessible :name, :total_votes, :max_poems, :created_at, :updated_at, :active
  has_many :auth_lang_relations, :dependent => :destroy
  has_many :authors, :through => :auth_lang_relations
  has_many :poems

  def add_author!(author)
    authors << author
  end

  def remove_author!(author)
    auth_lang_relations.find_by_author_id(author).destroy
  end

  def has_author?(author)
    auth_lang_relations.find_by_author_id(author)
  end

  def gen_poem
    num_lines = rand(max_lines - min_lines + 1) + min_lines
    lines = num_lines.times.collect { gen_line }
    full_text = lines.collect { |l| l.display }.join("<br \>\n")
    prog_text = lines.collect { |l| l.to_prog_text }.join(" BREAK ")

    poems.build(:full_text => full_text, :programmatic_text => prog_text)
  end

  def language
    @@languages ||= {}
    return @@languages[name] if @@languages[name]
    
    reload_language
    @@languages[name]
  end

  def gen_line
    language.gen_line
  end

  def reload_language
    @@languages[name] = MarkovLanguage.new

    authors.each do |author|
      author.works.each do |work|
        text = work.content.gsub(/\n/, " ")
        text = text.gsub(/["\[\]\(\)\{\}]/, "")
        @@languages[name].add_snippet(text) 
      end
    end
  end

  private 


end
