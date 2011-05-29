module PoemsHelper

#######################
# Text helper methods #
#######################
  def born_fmt(poem, include_ago = true)
    if include_ago
      time_ago(poem.created_at)
    else
      date_fmt(poem.created_at)
    end
  end

  def died_fmt(poem, include_ago = true)
    if poem.alive?
      "Still Alive"
    elsif include_ago
      time_ago(poem.died_on)
    else
      date_fmt(poem.died_on)
    end
  end

  def alive_dates(poem)
    if poem.alive?
      "#{born_fmt(poem, false)} &ndash; present"
    else
      "#{born_fmt(poem, false)} &ndash; #{died_fmt(poem, false)}"
    end.html_safe
  end

  def time_ago(time)
    "#{date_fmt(time)} (#{time_ago_in_words(time)} ago)"
  end

#################
# Misc. Methods #
#################

  def children_links(poem)
    if poem.all_children.empty?
      ""
    else
      links = poem.all_children.collect.with_index do |child, i|
        link = link_to("##{child.id}", poem_path(child) )

        other_parent_link = if child.second_parent.nil?
          " (mother)"
        elsif child.second_parent == poem
          " (father with " + link_to("##{child.parent.id}", poem_path(child.parent) ) + " as the mother)"
        else
          " (mother with " + link_to("##{child.second_parent.id}", poem_path(child.second_parent) ) + " as the father)"
        end

        "<li>" + link + other_parent_link + "</li>"
      end.join
      ("<ul><strong>Children:</strong>" + links + "</ul>").html_safe
    end
  end

#######################
# Family Tree Methods #
#######################

  def family_tree(poem)
    struct = poem.fam_tree_struct_with_lines
    struct.collect do |line|
      middle_text = line.collect { |elem| struct_elem(elem, poem) }.join("\n")
      line_width = line.length * 200;
      %{<div class="fam-tree-row" style="width: #{line_width}px;">\n} + middle_text + clear + %{</div>}
    end.join("\n").html_safe
  end

  def struct_elem(elem, original_poem)
    if elem.class == Poem
      family_tree_leaf(elem, original_poem)
    elsif elem.nil?
      line_template
    else
      case elem
      when '['
        left_edge_line
      when ']'
        right_edge_line
      when 'T'
        t_line
      when '-'
        horizontal_line
      when '|'
        vertical_line
      end
    end
  end

  def family_tree_leaf(poem, original_poem)
    mark_as_this_poem = poem.id == original_poem.id
    render :partial => "poem_leaf", :locals => {:poem => poem, :mark_as_this_poem => mark_as_this_poem}
  end

##############################
# Lines for the family trees #
##############################

  def line_template(ul = nil, ur = nil, ll = nil, lr = nil)
    ur ||= "unmarked"
    ul ||= "unmarked"
    lr ||= "unmarked"
    ll ||= "unmarked"
    html = <<-eol
    <div class="fam-tree-line-container">
      <div class="fam-tree-line-level">
        <div class="fam-tree-#{ul}"></div>
        <div class="fam-tree-#{ur}"></div>
        #{clear}
      </div>
      <div class="fam-tree-line-level">
        <div class="fam-tree-#{ll}"></div>
        <div class="fam-tree-#{lr}"></div>
        #{clear}
      </div>
    </div>
    eol
    html.html_safe
  end

  def left_edge_line
    line_template("marked-right","marked-bottom","marked-right")
  end

  def right_edge_line
    line_template("marked-bottom",nil,"marked-right")
  end

  def t_line
    line_template("marked-bottom","marked-bottom","marked-right")
  end

  def horizontal_line
    line_template("marked-bottom","marked-bottom")
  end

  def vertical_line
    line_template("marked-right",nil, "marked-right")
  end
end
