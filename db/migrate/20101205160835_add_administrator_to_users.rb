class AddAdministratorToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :admin, :boolean
    add_column :users, :points_used, :integer, :default => 0

    remove_column :users, :points
    add_column :users, :total_points, :integer, :default => 0

    add_index :users, :username
  end

  def self.down
    remove_column :users, :admin
    remove_column :users, :points_used

    remove_column :user, :total_points
    add_column :users, :points, :integer, :default => 0

    remove_index :users, :username
  end
end
