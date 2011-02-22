module PoemsHelper
  def born_fmt(poem)
    time_ago(poem.created_at)
  end

  def died_fmt(poem)
    if poem.alive?
      "Still Alive"
    else
      time_ago(poem.died_on)
    end
  end

  def time_ago(time)
    "#{time.to_date.to_s(:long_ordinal)} (#{time_ago_in_words(time)} ago)"
  end

  def children_links(poem)
    if poem.all_children.empty?
      ""
    else
      links = poem.all_children.collect.with_index do |child, i|
        link = link_to "Child #{i + 1}", poem_path(child)
        "<li>" + link + "</li>"
      end.join
      ("<ul><strong>Children:</strong>" + links + "</ul>").html_safe
    end
  end
end
