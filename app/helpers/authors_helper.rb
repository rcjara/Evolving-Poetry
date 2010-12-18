module AuthorsHelper
  def works_links(author)
    author.works.collect do |work|
      "<li>" + link_to(work.title, work) + "</li>"
    end.join("\n").html_safe
  end

  def authors_anchor_links(authors)
    authors.collect do |a| 
      "<li>" + author_anchor_link(a) + "</li>"
    end.join("\n").html_safe
  end

  def author_anchor_link(author)
    link_to author.full_name, :controller => 'authors',
                              :action => 'index',
                              :anchor => "author_#{author.id}"
  end
end
