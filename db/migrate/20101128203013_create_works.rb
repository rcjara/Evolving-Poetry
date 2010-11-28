class CreateWorks < ActiveRecord::Migration
  def self.up
    create_table :works do |t|
      t.integer :author_id
      t.string :content
      t.string :title

      t.timestamps
    end

    add_index :works, :author_id
  end

  def self.down
    drop_table :works
  end
end
