module AuthorsHelper
  def works_links(author)
    author.works.collect do |work|
      "<li>" + link_to(work.title, work) + "</li>"
    end.join("\n").html_safe
  end
end
