class Language < ActiveRecord::Base
  include LanguagesHelper

  attr_accessible :name, :total_votes, :max_poems, :created_at,
    :updated_at, :active, :description, :min_lines, :max_lines,
    :cur_family, :num_families, :poems_sexually_reproduced,
    :poems_asexually_reproduced, :visible

  has_many :auth_lang_relations, :dependent => :destroy
  has_many :authors, :through => :auth_lang_relations
  has_many :poems

  scope :visible, where('visible = ?', true)
  scope :active,  visible.where('active = ?', true)

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

  def quick_evolution_poems(orig_poem = nil)
    orig_poem ||= gen_poem
    other_poems = 3.times.collect do
      orig_poem.quick_evolution_reproduce
    end
    [orig_poem, other_poems]
  end

  def gen_poem
    num_lines = rand(max_lines - min_lines + 1) + min_lines
    p = evolver.new_poem(num_lines)
    from_markov(p)
  end

  def gen_poem!
    new_poem = gen_poem
    increment_family!
    new_poem.family = self.num_families
    new_poem.save
    new_poem
  end

  def from_markov(p)
    poems.build(:full_text => p.display, :programmatic_text => p.to_prog_text)
  end

  def from_prog_text(prog_text, strip = true)
    markov_poem = MarkovPoem.from_prog_text(prog_text,
      self.markov, :strip => strip)
    from_markov(markov_poem)
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
    increment!(:num_families)
  end

  def increment_sexual_poems!
    increment!(:poems_sexually_reproduced)
  end

  def increment_asexual_poems!
    increment!(:poems_asexually_reproduced)
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
    increment!(:total_votes)
  end

  def markov
    @@languages ||= {}
    return @@languages[name] if @@languages[name]

    reload_language
    @@languages[name]
  end

  def evolver
    @evolver ||= Markov::Evolver.new(markov)
  end

  def gen_line
    markov.gen_line
  end

  def reload_language
    @@languages[name] = Markov::Language.new

    authors.each do |author|
      author.works.each do |work|
        text = work.content
                   .gsub(/"/, " ")
                   .gsub(/\s'|'\s/, " ")
                   .gsub(/[\[\]\(\)\{\}]/, "")
        @@languages[name].add_snippet(text)
      end
    end
  end
end
