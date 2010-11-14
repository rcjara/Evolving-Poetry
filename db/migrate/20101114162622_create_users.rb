class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username
      t.string :email
      t.integer :poems_evaluated, :default => 0
      t.integer :posts, :default => 0
      t.integer :points, :default => 0
      t.timestamps
    end

    add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  end

  def self.down
    drop_table :users
  end
end
