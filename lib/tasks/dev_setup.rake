namespace :db do 
  desc "Set up the environment for development"
  task :dev_setup => :environment do 
    Rake::Task['db:process_works'].invoke
    create_languages
    simulate_voting
  end
end

def create_languages
  create_mega_language
  create_small_languages
end

def create_mega_language
  lang = Language.create!(:name => "All authors", :description => "An amalgamation of all the authors")
  puts "Creating language for all authors"
  Author.all.each do |auth|
    lang.add_author!(auth)
  end
  gen_poems_for_lang(lang)
end

def create_small_languages
  Author.all.each do |auth|
    puts "Creating language for #{auth.full_name}"
    lang = Language.create!(:name => "#{auth.full_name}'s Language", :description => "A language of #{auth.full_name}'s own.")
    lang.add_author!(auth)
    gen_poems_for_lang(lang)
  end
end

def gen_poems_for_lang(lang)
  lang.max_poems.times { lang.gen_poem! }
end

def simulate_voting
  Language.all.each do |lang|
    puts "Voting for #{lang.description}"
    1000.times do
      poem1, poem2 = lang.poems_for_voting
      poem1.vote_for!
      poem2.vote_against!
    end
  end
end
