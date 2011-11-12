namespace :db do
  desc "Set up the environment for development"
  task :dev_setup => :environment do
    Rake::Task['db:process_works'].invoke
    Rake::Task['db:dev_users'].invoke
    create_languages
    gen_poems_for_languages
    simulate_voting
  end
end

namespace :db do
  desc "Set up the environment for deployment"
  task :deploy_setup => :environment do
    Rake::Task['db:process_works'].invoke
    create_languages
  end
end

def create_languages
  create_small_languages
  create_mega_language
end

def create_mega_language
  lang = Language.create!(:name => "All authors", :description => "An amalgamation of all the authors.")
  puts "Creating language for all authors"
  Author.visible.each do |auth|
    lang.add_author!(auth)
  end
end

def create_small_languages
  Author.all.each do |auth|
    puts "Creating language for #{auth.full_name}"
    lang = Language.create!(:name => "#{auth.full_name}'s Language", :description => "A language of #{auth.full_name}'s own.")
    lang.add_author!(auth)
  end

  Language.first.tap do |wl|
    wl.visible = false
    wl.active = false
    wl.save!
  end
end


def gen_poems_for_languages
  len = Language.visible.length
  all_len = Language.all.length
  puts "Generating poems - (#{len} / #{all_len})"
  Language.visible.each do |lang|
    print "  for #{lang.description} "
    lang.max_poems.times do
      lang.gen_poem!
      print '.'
    end
    print "\n"
  end
end

def simulate_voting
  Language.visible.each do |lang|
    puts "Voting for #{lang.description}"
    250.times do
      poem1, poem2 = lang.poems_for_voting(true)
      poem1.vote_for!
      poem2.vote_against!
    end
  end
end
