class Poem < ActiveRecord::Base
  attr_accessible :full_text, :programmatic_text, :language_id, :votes_for,
    :votes_against, :score, :alive, :died_on, :num_children, :family,
    :second_family, :second_parent_id
  belongs_to :language
  belongs_to :parent, :class_name => 'Poem',
    :foreign_key => :parent_id
  belongs_to :second_parent, :class_name => 'Poem',
    :foreign_key => :second_parent_id
  has_many :children, :class_name => 'Poem',
    :foreign_key => :parent_id
  has_many :second_children, :class_name => 'Poem',
    :foreign_key => :second_parent_id

  scope :alive,    where('alive = ?', true)
  scope :by_score, alive.order('(votes_for - votes_against) / (votes_against + 1.0) DESC')
  scope :top,      by_score.limit(1)
  scope :top_5,    by_score.limit(5)
  scope :all_time, order('votes_for')
  scope :dead,     where('alive =?', false).order('votes_for')

  def inspect
    "<Poem: #{self.id}>"
  end

  def vote_for!
    Hash.new.tap do |response|
      language.add_vote!
      increment(:votes_for)
      increment(:score)


      if votes_til_birth <= 0
        response[:gave_birth] = true
        response[:child] = bear_child.id
      end

      response[:voted_for] = self.id
      response[:save_status] = save
      response[:votes_til_birth] = votes_til_birth
    end
  end

  def vote_against!
    Hash.new.tap do |response|
      increment(:votes_against)
      decrement(:score)

      check_for_death!

      unless self.alive
        response[:died] = true
        response[:died_on] = self.died_on
      end

      response[:voted_against] = self.id
      response[:votes_til_death] = votes_til_death
      response[:save_status] = save
    end
  end

  def votes_til_birth
    Constants::BEAR_CHILD_CUTOFF - self.score
  end

  def votes_til_death
    (self.votes_for - self.votes_against) - Constants::STILL_ALIVE_CUTOFF
  end

  def all_children
    children + second_children
  end

  def check_for_death!
    if votes_til_death <= 0
      self.alive = false
      self.died_on = Time.now
      self.language.alert_of_death!
    end
  end

  def bear_child
    self.score = 0

    if(rand(Constants::SEX_ODDS + Constants::MUTATE_ODDS) < Constants::MUTATE_ODDS)
      asexually_reproduce!
    else
      sexually_reproduce!
    end
  end

  def markov_asexual
    MarkovPoem.from_prog_text(self.programmatic_text, self.language.markov, :strip => true).tap do |markov_poem|
      (rand(Constants::MAX_MUTATIONS) + 1).times{ markov_poem.mutate!(self.language.markov) }
    end
  end

  def asexually_reproduce!
    new_markov_poem = markov_asexual
    self.children.build(:family => self.family, :language_id => self.language_id,
      :programmatic_text => new_markov_poem.to_prog_text,
      :full_text => new_markov_poem.display).
    tap do |new_poem|
      if new_poem.save
        language.increment_asexual_poems!
        self.num_children += 1
        self.save
      end
    end
  end

  def sexually_reproduce!
    potential_mates = self.language.poems.top_5
    mate = self
    mate = potential_mates.sample while mate == self
    sexually_reproduce_with!(mate)
  end

  def sexually_reproduce_with!(other_poem)
    new_markov_poem = markov_form.sexually_reproduce_with(other_poem.markov_form, self.language.markov)
    new_poem = self.children.build :family => self.family,
      :language_id => self.language_id,
      :second_family => other_poem.family,
      :full_text => new_markov_poem.display,
      :programmatic_text => new_markov_poem.to_prog_text
    new_poem.save
    other_poem.second_children << new_poem

    if new_poem.save
      language.increment_sexual_poems!
      self.num_children += 1
      self.save
    end

    new_poem
  end

  def create_identical_child
    self.children.build :full_text => self.full_text, :programmatic_text => self.programmatic_text,
      :family => self.family, :language_id => self.language_id
  end

  def markov_form
    MarkovPoem.from_prog_text(self.programmatic_text, self.language.markov)
  end

  def family_members
    self.language.poems.where('family = ?', self.family).order('id')
  end

  def family_tree(opts = {})
    FamilyTree.new(family_members).structure(opts)
  end

  def bastards
    ChildrenWithFathers.new(self.children).bastards
  end

  def children_by_father
    ChildrenWithFathers.new(self.children).by_father
  end
end

