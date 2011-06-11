class AddPoemsSexuallyReproducedToLanguages < ActiveRecord::Migration
  def self.up
    remove_column :languages, :cur_family
    add_column :languages, :num_families, :integer, :default => 0

    add_column :languages, :poems_sexually_reproduced,  :integer, :default => 0
    add_column :languages, :poems_asexually_reproduced, :integer, :default => 0
  end

  def self.down
    remove_column :languages, :poems_sexually_reproduced
    remove_column :languages, :poems_asexually_reproduced

    remove_column :languages, :num_families
    add_column :cur_family, :default => 1
  end
end
