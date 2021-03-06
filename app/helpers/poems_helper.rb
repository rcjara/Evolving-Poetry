module PoemsHelper

#######################
# Html helper methods #
#######################
  def poem_link(poem)
    if poem.id
      link_to Constants::POEM_NAME + poem.id.to_s, poem
    else
      "Poem titled: Still forming in the nonsense womb."
    end
  end

  def poem_id_link(p_id)
    if p_id
      link_to Constants::POEM_NAME + p_id.to_s, poem_path(p_id)
    end
  end

  def mother_link(poem)
    poem_id_link poem.parent_id
  end

  def father_link(poem)
    poem_id_link poem.second_parent_id
  end


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

  #time of death
  def tod_fmt(poem)
    time_fmt(poem.died_on)
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
    struct = poem.family_tree
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

#############################
# Lines for the parent view #
#############################

  def short_vertical_line
    html = <<-eol
      <div class="short-line-container">
        <div class="fam-tree-marked-right"></div>
        <div class="fam-tree-unmarked"></div>
      </div>
    eol
    html.html_safe
  end

  def narrow_t
    html = <<-eol
      <div class="narrow-t-container">
        <div class="short-t-gap"></div>
        <div class="short-t-container">
          <div class="fam-tree-marked-top-right"></div>
          <div class="fam-tree-marked-top"></div>
        </div>
      </div>
    eol
    html.html_safe
  end

##############################
# Lines for the family trees #
##############################

  def line_template(ul = 'unmarked', ur = 'unmarked', ll = 'unmarked', lr = 'unmarked')
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
