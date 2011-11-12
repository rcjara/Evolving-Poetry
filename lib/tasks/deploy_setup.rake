namespace :db do
  desc "Set up the environment for deployment"
  task :deploy_setup => :environment do
    Rake::Task['db:process_works'].invoke
    TasksHelper::create_languages
  end
end

