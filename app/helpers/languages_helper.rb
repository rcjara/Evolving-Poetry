module LanguagesHelper
  def author_links(language)
    proper_list(language.authors.collect do |auth|
      link_to auth.full_name, auth
    end).html_safe 
  end

end
