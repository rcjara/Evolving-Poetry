module LanguagesHelper
  def author_links(language)
    proper_list(language.authors.collect do |auth|
      author_anchor_link auth
    end).html_safe 
  end

end
