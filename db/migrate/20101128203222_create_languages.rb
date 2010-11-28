class CreateLanguages < ActiveRecord::Migration
  def self.up
    create_table :languages do |t|
      t.string :name
      t.integer :total_votes
      t.integer :max_poems

      t.timestamps
    end
  end

  def self.down
    drop_table :languages
  end
end
