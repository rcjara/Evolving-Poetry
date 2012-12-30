module MarkovHelper
  def poe_language
    @poe_language ||= Markov::Language.new.tap do |lang|
      text = File.read(File.expand_path(File.dirname(__FILE__) + '/../../lib/works/edgar_allan_poe.txt'))
      lang.add_snippet(text)
    end
  end
end
