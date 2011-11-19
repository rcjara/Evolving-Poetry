namespace :graph do
  desc "Make a simplified graph out of the welcome language"
  task :simplified => :environment do
    lang      = Language.first.markov
    file_name = Rails.root.join('dev_temp/graphs/nonsense_welcome').to_s
    GraphGenerator::gen_simplified(file_name, lang, 14)
  end
end
