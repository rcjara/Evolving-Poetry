class CreateAuthorLanguageRelations < ActiveRecord::Migration
  def self.up
    create_table :author_language_relations do |t|
      t.integer :author_id
      t.relation :language_id

      t.timestamps
    end
  end

  def self.down
    drop_table :author_language_relations
  end
end
