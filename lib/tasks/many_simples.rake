namespace :graph do
  desc "Make many simplified graphs out of the welcome language"
  task :many_simples => :environment do
    lang      = Language.first.markov
    file_name = Rails.root.join('dev_temp/graphs/nonsense_welcome').to_s
    (10..20).each do |n|
      n_name = "#{file_name}_#{n}"
      puts n_name
      GraphGenerator::gen_simplified(n_name, lang, n)
    end
  end
end

