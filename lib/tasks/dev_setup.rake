namespace :db do
  desc "Set up the environment for development"
  task :dev_setup => :environment do
    Rake::Task['db:process_works'].invoke
    Rake::Task['db:dev_users'].invoke
    TasksHelper::create_languages
    TasksHelper::gen_poems_for_languages
    TasksHelper::simulate_voting
  end
end
