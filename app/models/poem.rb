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

  def inspect
    "<Poem: #{self.id}>"
  end

  def vote_for!
    language.add_vote!
    self.votes_for += 1
    self.score += 1

    bear_child if votes_til_birth <= 0

    save
  end

  def votes_til_birth
    Constants::BEAR_CHILD_CUTOFF - self.score
  end

  def votes_til_death
    (self.votes_for - self.votes_against) - Constants::STILL_ALIVE_CUTOFF
  end

  def vote_against!
    self.votes_against += 1
    self.score -= 1

    check_for_death!

    save
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

# Making Family Trees (A guide)
# fam_tree_struct
#   -- find the first family member, call sub_fam_tree on it passing in family members(for quick reference)
#
# sub_fam_tree
#   -- find your children...
#   -- make two lines, with you at top, and all your children's sub arrays in the second

  def display_fam_tree_struct(with_lines)
    tree = if with_lines
      fam_tree_struct_with_lines
    else
      fam_tree_struct
    end

    FamilyTreeCompressor::string(tree)
  end

  def fam_tree_struct(attr = {})
    add_lines = true if attr[:add_lines]

    fam_members = family_members
    fam_members.values.first.sub_fam_tree(fam_members, add_lines)
  end

  def fam_tree_struct_with_lines
    fam_tree_struct :add_lines => true
  end

  def sub_fam_tree(fam_members, add_lines = false)
    tree_children = get_tree_children(fam_members)
    return [[self]] if tree_children.empty?

    children_trees       = tree_children.collect { |p| p.sub_fam_tree(fam_members, add_lines) }
    children_trees_array = collapse_child_trees(children_trees, add_lines)
    self_line = [self] + [nil] * (children_trees_array[0].length - 1)

    final_array = if add_lines
      [self_line, lines_array(children_trees_array[0])] + children_trees_array
    else
      [self_line] + children_trees_array
    end

    if add_lines
      FamilyTreeCompressor::compress(final_array)
    else
      final_array
    end
  end

  def collapse_child_trees(array_of_arrays, add_lines)
    max_depth = array_of_arrays.inject(0){|depth, array| array.length > depth ? array.length : depth }
    final_array = max_depth.times.collect{ [] }

    array_of_arrays.each do |array|
      this_length = array[0].length
      (0...max_depth).each do |i|
        to_add = array[i] ? array[i] : [nil] * this_length
        final_array[i] += to_add
      end
    end

    final_array
  end

  def family_members
    array = self.language.poems.where('family = ? OR second_family = ?', self.family, self.family).order('id')
    hash = {}
    array.each do |p|
      hash[p.id] = p
    end
    hash
  end

  def get_tree_children(fam_members)
    fam_members.values.select{ |p| p.parent == self || p.second_parent == self }
  end

  def lines_array(immediate_children)
    end_point = immediate_children.length - 1
    return ["|"] if end_point == 0
    immediate_children.collect.with_index do |child, i|
      if i == 0
        "["
      elsif i == end_point
        "]"
      else
        child ? "T" : "-"
      end
    end
  end

end

