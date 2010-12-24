class AddParentsAndFamiliesToPoems < ActiveRecord::Migration
  def self.up
    add_column :poems, :parent_id, :integer
    add_column :poems, :second_parent_id, :integer
    add_column :poems, :family, :integer
    add_column :poems, :second_family, :integer

    add_column :languages, :cur_family, :integer, :default => 1

    add_index :poems, :parent_id
    add_index :poems, :second_parent_id
    add_index :poems, :family
    add_index :poems, :second_family
  end

  def self.down
    remove_column :poems, :second_family
    remove_column :poems, :family
    remove_column :poems, :second_parent_id
    remove_column :poems, :parent_id

    remove_column :languages, :cur_family

    remove_index :poems, :parent_id
    remove_index :poems, :second_parent_id
    remove_index :poems, :family
    remove_index :poems, :second_family
  end
end
