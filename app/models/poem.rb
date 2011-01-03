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

  def vote_for!
    language.add_vote!
    self.votes_for += 1
    self.score += 1

    bear_child if self.score > Constants::BEAR_CHILD_CUTOFF

    save
  end

  def vote_against!
    self.votes_against += 1
    self.score -= 1

    check_for_death!

    save
  end

  def check_for_death!
    if self.votes_for - self.votes_against < Constants::STILL_ALIVE_CUTOFF
      self.alive = false
      self.language.alert_of_death!
    end
  end
  
  def bear_child
    self.score = 0
    self.save

    if(rand(Constants::SEX_ODDS + Constants::MUTATE_ODDS) < Constants::MUTATE_ODDS)
      asexually_reproduce!
    else
      sexually_reproduce!
    end
  end

  def asexually_reproduce!
    new_markov_poem = MarkovPoem.from_prog_text(self.programmatic_text, self.language.markov, :strip => true)
    (rand(Constants::MAX_MUTATIONS) + 1).times{ new_markov_poem.mutate!(self.language.markov) }
    new_poem = self.children.build(:family => self.family, :language_id => self.language_id,
      :programmatic_text => new_markov_poem.to_prog_text, :full_text => new_markov_poem.display)
    new_poem.save
    new_poem
  end

  def sexually_reproduce!
    potential_mates = self.language.top_5
    mate = self
    mate = potential_mates[rand(5)] while mate == self
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
    new_poem.save
    new_poem
  end

  def create_identical_child
    self.children.build :full_text => self.full_text, :programmatic_text => self.programmatic_text, 
      :family => self.family, :language_id => self.language_id
  end

  def markov_form
    MarkovPoem.from_prog_text(self.programmatic_text, self.language.markov)
  end
end

