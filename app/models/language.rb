class Language < ActiveRecord::Base
  include LanguagesHelper

  attr_accessible :name, :total_votes, :max_poems, :created_at,
    :updated_at, :active, :description, :min_lines, :max_lines,
    :cur_family, :num_families, :poems_sexually_reproduced,
    :poems_asexually_reproduced

  has_many :auth_lang_relations, :dependent => :destroy
  has_many :authors, :through => :auth_lang_relations
  has_many :poems

  scope :active, where('active = ?', true)

  def self.random
    Language.active.sample
  end

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

    increment_family!
    new_poem = poems.build(:full_text => p.display, :programmatic_text => p.to_prog_text, :family => self.num_families)
    new_poem.save
    new_poem
  end

  def poems_by(sorting)
    case sorting && sorting.to_sym
    when :all_time
      poems.all_time
    when :dead
      poems.dead
    else
      poems.by_score
    end
  end

  def total_poems
    poems.count
  end

  def increment_family!
    self.num_families += 1
    save
  end

  def increment_sexual_poems!
    self.poems_sexually_reproduced += 1
    save
  end

  def increment_asexual_poems!
    self.poems_asexually_reproduced += 1
    save
  end

  def alert_of_death!
    if self.poems.alive.length < self.max_poems
      gen_poem!
    end
  end

  def poems_for_voting(rigged = false)
    pool = poems.alive

    if rigged
      poem2 = poem1 = pool[0...4].sample
      while poem2 == poem1
        poem2 = pool.sample
      end
      [poem1, poem2]
    else
      pool.sample(2)
    end
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
        text.gsub!(/"/, " ")
        text.gsub!(/\s'|'\s/, " ")
        text.gsub!(/[\[\]\(\)\{\}]/, "")
        @@languages[name].add_snippet(text)
      end
    end
  end

  private


end
