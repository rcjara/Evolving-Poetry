#add defaults to a lot more than that.
class AddDefaultsToLanguages < ActiveRecord::Migration
  def self.up
    change_column :languages, :total_votes, :integer, :default => 0
    change_column :languages, :max_poems, :integer, :default => 20
    add_column :languages, :active, :boolean, :default => true

    add_column :authors, :visible, :boolean, :default => true

    change_column :poems, :alive, :boolean, :default => true
    change_column :poems, :votes_for, :integer, :default => 0
    change_column :poems, :votes_against, :integer, :default => 0
    change_column :poems, :score, :integer, :default => 0
    add_column :poems, :num_children, :integer, :default => 0

  end

  def self.down
    change_column :languages, :total_votes, :integer
    change_column :languages, :max_poems, :integer
    remove_column :languages, :active

    remove_column :authors, :visible

    change_column :poems, :alive, :boolean
    change_column :poems, :votes_for, :integer
    change_column :poems, :votes_against, :integer
    change_column :poems, :score, :integer
    remove_column :poems, :num_children
  end
end
