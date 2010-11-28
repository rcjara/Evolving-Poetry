class CreateAuthors < ActiveRecord::Migration
  def self.up
    create_table :authors do |t|
      t.string :first_name
      t.string :last_name
      t.string :full_name

      t.timestamps
    end

    add_index :authors, :first_name
    add_index :authors, :full_name
  end

  def self.down
    drop_table :authors
  end
end
