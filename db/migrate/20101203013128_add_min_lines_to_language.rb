class AddMinLinesToLanguage < ActiveRecord::Migration
  def self.up
    add_column :languages, :min_lines, :integer, :default => 4
    add_column :languages, :max_lines, :integer, :default => 15
  end

  def self.down
    remove_column :languages, :min_lines
    remove_column :languages, :max_lines
  end
end
