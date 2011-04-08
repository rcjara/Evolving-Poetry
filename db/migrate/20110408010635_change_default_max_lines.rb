class ChangeDefaultMaxLines < ActiveRecord::Migration
  def self.up
    change_column :languages, :max_lines, :integer, :default => 10
  end

  def self.down
    change_column :languages, :max_lines, :integer, :default => 15
  end
end
