class Language < ActiveRecord::Base
  include LanguagesHelper

  attr_accessible :name, :total_votes, :max_poems, :created_at, 
    :updated_at, :active, :description, :min_lines, :max_lines, 
    :cur_family

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

  def gen_poem!
    num_lines = rand(max_lines - min_lines + 1) + min_lines
    p = markov.gen_poem(num_lines)

    new_poem = poems.build(:full_text => p.display, :programmatic_text => p.to_prog_text, :family => self.cur_family)
    increment_family!
    new_poem.save
    new_poem
  end

  def increment_family!
    self.cur_family += 1
    save
  end

  def alert_of_death!
    if self.alive_poems.length < self.max_poems
      gen_poem!
    end
  end

  def poems_for_voting
    possibilities = alive_poems
    max = possibilities.length
    poem1 = poem2 = possibilities[rand(max)]
    while poem2 == poem1
      poem2 = possibilities[rand(max)]
    end
    [poem1, poem2]
  end

  def top_5
    alive_poems.order("(votes_for - votes_against) / (votes_against + 1.0) DESC").limit(5)
  end

  def alive_poems
    self.poems.where("alive = ?", true)
  end

  def add_vote!
    self.total_votes += 1
    save
  end

  def markov
    @@languages ||= {}
    return @@languages[name] if @@languages[name]
    
    reload_language
    @@languages[name]
  end

  def gen_line
    markov.gen_line
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
