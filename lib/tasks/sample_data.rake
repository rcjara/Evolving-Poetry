require 'faker'

namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    create_users
  end
end


def create_users
  User.create!(:username => "Example User",
    :email => "raul.c.jara@gmail.com",
    :password => "foobar",
    :password_confirmation => "foobar")
end
