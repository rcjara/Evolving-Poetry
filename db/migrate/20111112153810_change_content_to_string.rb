class ChangeContentToString < ActiveRecord::Migration
  def self.up
    remove_column :works, :content
    remove_column :works, :title
    add_column :works, :content, :text
    add_column :works, :title, :text
  end

  def self.down
    remove_column :works, :content
    remove_column :works, :title
    add_column :works, :content, :string
    add_column :works, :title, :string
  end
end
