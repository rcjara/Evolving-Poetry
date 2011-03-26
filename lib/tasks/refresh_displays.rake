namespace :db do 
  desc "Refresh poem's displays"
  task :refresh_display => :environment do 
    total_length = Poem.all.length
    Poem.all.each_with_index do |poem, i|
      print '.' if i % (total_length / 5) == 0
      poem.full_text = poem.markov_form.display
      poem.save
    end
    puts ""
  end
end
