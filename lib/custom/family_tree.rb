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

    tree_children = children_hash[parent]
    return [[parent]] if tree_children.empty?

    children_trees       = tree_children.collect { |p| sub_tree(p) }
    children_trees_array = collapse_child_trees(children_trees)

    #extra nils if the children trees are longer than one
    parent_line = [parent] + [nil] * (children_trees_array[0].length - 1)

    final_array = if opts[:lines]
      [parent_line, lines_array(children_trees_array[0]) ] + children_trees_array
    else
      [parent_line] + children_trees_array
    end

    if opts[:lines]
      FamilyTreeCompressor::compress(final_array)
    else
      final_array
    end
  end

  def collapse_child_trees(lines)
    max_depth = lines.inject(0){|depth, line| [line.length, depth].max }
    final_array = max_depth.times.collect{ [] }

    lines.each do |line|
      this_length = line[0].length
      (0...max_depth).each do |i|
        to_add = line[i] ? line[i] : [nil] * this_length
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
