WORKS_FILES_REGEX = /^\@(.+?)\n(.+?)(?=^\@)/m

namespace :db do
  desc "Create a fresh database"
  task :process_works => :environment do
    Rake::Task['db:reset'].invoke
    puts "Now onto process_works_files"
    process_works_files
  end
end

def process_works_files
  path = File.dirname(File.expand_path(__FILE__)) + '/../works/'
  dir = Dir.new(path)
  file_names = dir.select {|f| f =~ /.*\.txt$/}

  #ensure that nonsense welcome comes first
  file_names.unshift( file_names.delete "nonsense_welcome.txt" )

  puts "#{file_names.length} files."

  file_names.each do |fn|
    puts "processing.. #{fn}"
    author_names = fn.scan(/(.+?)(\.txt)/)[0][0].split("_")
    author_names.each { |an| an.capitalize! }
    first_name = author_names.first
    last_name = author_names.last
    full_name = author_names.join(" ")

    author = Author.create!(:first_name => first_name,
                            :last_name => last_name,
                            :full_name => full_name)

    text = File.read(path + fn)
    works = text.scan WORKS_FILES_REGEX
    works.each do |regex_result|
      title = regex_result[0]
      puts ".. #{title}"
      text = regex_result[1]
      author.works.create!(:title => title, :content => text)
    end

  end

  #make sure that the welcome language author is invisible
  Author.first.tap do |w|
    w.visible = false
    w.save!
  end

end
