class FamilyTree
  def initialize(fam_members)
    @fam_members = fam_members
  end

  def children_hash
    @children_hash ||= make_children_hash
  end

  def make_children_hash
    (Hash.new { [] }).tap do |h|
      @fam_members.each do |child|
        h[child.parent] += [child]
      end
    end
  end

  def structure(opts = {})
    sub_tree @fam_members[0], opts
  end

  def display
    structure.collect do |line|
      line.collect { |item| display_item(item) }.join(' ')
    end.join("\n") + "\n"
  end

  def display_item(item)
    if item.nil?
      '.'
    elsif item.class == String
      item
    else
      'p'
    end
  end

  def sub_tree(parent, pre_opts = {})
    opts = {lines: true}.merge pre_opts

    immediate_children = children_hash[parent]
    return [[parent]] if immediate_children.empty?

    sub_trees          = immediate_children.collect { |p| sub_tree(p) }
    gathered_sub_trees = collapse_child_trees(sub_trees)

    #extra nils if the children trees are longer than one
    parent_line = [parent] + [nil] * (gathered_sub_trees[0].length - 1)

    if opts[:lines]
      array = [parent_line, lines_array(gathered_sub_trees[0]) ] + gathered_sub_trees
      FamilyTreeCompressor::compress(array)
    else
      [parent_line] + gathered_sub_trees
    end
  end

  def collapse_child_trees(lines)
    max_depth = lines.inject(0){|depth, line| [line.length, depth].max }
    final_array = max_depth.times.collect{ [] }

    lines.each do |line|
      width = line[0].length
      (0...max_depth).each do |i|
        to_add = line[i] ? line[i] : [nil] * width
        final_array[i] += to_add
      end
    end

    final_array
  end

  def lines_array(immediate_children)
    last_index = immediate_children.reverse.index { |o| !o.nil? }
    last_index ||= 0

    end_point = immediate_children.length - 1 - last_index

    return ["|"] if end_point == 0
    immediate_children.collect.with_index do |child, i|
      if i == 0
        "["
      elsif i == end_point
        "]"
      else
        child ? "T" : "-"
      end
    end
  end

end
