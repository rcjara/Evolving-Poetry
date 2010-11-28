class CreatePoems < ActiveRecord::Migration
  def self.up
    create_table :poems do |t|
      t.text :full_text
      t.text :programmatic_text
      t.integer :language_id
      t.integer :votes_for
      t.integer :votes_against
      t.integer :score
      t.bool :alive
      t.datetime :died_on

      t.timestamps
    end

    add_index :poems, :language_id
  end

  def self.down
    drop_table :poems
  end
end
