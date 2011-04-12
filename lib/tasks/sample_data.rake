require 'faker'

namespace :db do
  desc "Fill database with sample data"
  task :dev_users => :environment do
    create_users
  end
end


def create_users
  User.create!(:username => "Example User",
    :email => "raul.c.jara@gmail.com",
    :password => "foobar",
    :password_confirmation => "foobar")
end
