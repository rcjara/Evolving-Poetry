class Poem < ActiveRecord::Base
  attr_accessible :full_text, :programmatic_text, :language_id, :votes_for, :votes_against, :score, :alive, :died_on, :num_children, :family, :other_family
  belongs_to :language
  belongs_to :parent, :class_name => 'Poem', :foreign_key => :parent_id
  belongs_to :second_parent, :class_name => 'Poem', :foreign_key => :second_parent_id
  has_many :children, :class_name => 'Poem', :foreign_key => :parent_id
  has_many :second_children, :class_name => 'Poem', :foreign_key => :second_parent_id

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

    if self.votes_for - self.votes_against < Constants::STILL_ALIVE_CUTOFF
      self.alive = false
    end

    save
  end

  def create_identical_child
    self.children.build :full_text => self.full_text, :programmatic_text => self.programmatic_text, :family => self.family, :language_id => self.language

  end

  def markov_form
    MarkovPoem.from_prog_text(self.programmatic_text, self.language.markov)
  end
end

