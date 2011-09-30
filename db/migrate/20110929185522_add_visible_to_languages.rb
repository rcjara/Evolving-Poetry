class AddVisibleToLanguages < ActiveRecord::Migration
  def self.up
    add_column :languages, :visible, :boolean, :default => true
  end

  def self.down
    remove_column :languages, :visible
  end
end
