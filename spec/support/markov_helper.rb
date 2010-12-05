module MarkovHelper
  def array_of_tweets
    File.open(File.expand_path(File.dirname(__FILE__) + '/config/Tweets')) {|f| f.map{|line| line.chomp} }
  end
  
  def array_of_cleaned_tweets
    File.open(File.expand_path(File.dirname(__FILE__) + '/config/TweetsCleanedUp')) {|f| f.map{|line| line.chomp.toutf8} }
  end
  
  def array_of_processed_tweets
    File.open(File.expand_path(File.dirname(__FILE__) + '/config/TestResults')) {|f| f.map{|line| line.chomp.toutf8} }
  end
  
  def nouns_to_markov_words(nouns)
    nouns.collect { |noun| MarkovWord.new(noun, "the") }
  end

  def poe_language
    lang = MarkovLanguage.new
    File.open(File.expand_path(File.dirname(__FILE__) + '/../../lib/works/edgar_allan_poe.txt')) do |f| 
      f.each{ |line| lang.add_snippet(line) } 
    end
    lang
  end
end
