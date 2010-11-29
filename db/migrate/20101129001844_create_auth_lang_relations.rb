class CreateAuthLangRelations < ActiveRecord::Migration
  def self.up
    create_table :auth_lang_relations do |t|
      t.integer :author_id
      t.integer :language_id

      t.timestamps
    end

    add_index :auth_lang_relations, :author_id
    add_index :auth_lang_relations, :language_id
  end

  def self.down
    drop_table :auth_lang_relations
  end
end
