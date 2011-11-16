namespace :graphs do
  desc "Make a simplified graph out of the welcome language"
  task :simplified => :environment do
    lang      = Language.first.markov
    file_name = Rails.root.join('public/images/graphs/nonsense_welcome').to_s
    GraphGenerator::gen_simplified(file_name, lang, 20)
    File.delete(file_name + '.dot')
  end
end
