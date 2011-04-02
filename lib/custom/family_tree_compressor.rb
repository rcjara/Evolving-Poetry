module FamilyTreeCompressor
  #This is a module written in the functional style.
  #It assumes properly formed family trees ---with_lines---.
  #It compresses family trees so that they don't have long
  #stretches of '-','-','-' unless absolutely necessary.
  def self.compress(family_tree)
    return family_tree if family_tree.length < 3 #there is nothing to 
      # compress until the tree has 3 real lines (+ 2 lines showing 
      # the relations between the lines)
    blank_regions = identify_blank_regions(family_tree)
    return family_tree unless blank_regions

    new_tree = family_tree.collect{ |line| line.dup } # array of arrays
    blank_regions.reverse! #to work right to left
    blank_regions.each do |region|
      region_length = region[1] - region[0] + 1
      edges = edges_for_index(new_tree, region[1])
      slide_length = edges.inject(region_length) do |min, edge|
        edge_gap = edge[1] - edge[0] - 1 
        min < edge_gap ? min : edge_gap
      end

      next if slide_length == 0

      new_tree = slide(new_tree, region, edges, slide_length)
    end

    new_tree
  end

  def self.slide(tree, region, edges, slide_length)
    tree.collect.with_index do |line, i|
      if i < 3
        line.slice!(region[0], slide_length)
      else
        # (i - 4) is because the edges only start after for line 4 (at 0)
        # / 2 is because the edges skip the non-poem lines
        # [0] is to acess the left edge
        # + 1 is to get the first nil space
        cut_index = edges[(i - 3) / 2][0] + 1
        line.slice!(cut_index, slide_length)
      end

      line
    end
  end

  def self.string(family_tree)
    family_tree.collect do |line|
      line.collect do |item|
        if item.nil?
          '.'
        elsif item.class == Poem
          'p'
        else
          item
        end
      end.join(" ")
    end.join("\n") + "\n"
  end
  
  def self.identify_blank_regions(family_tree)
    return nil unless family_tree.length > 3 #there is nothing to 
      # compress until the tree has 3 real lines (+ 2 lines showing 
      # relations)
    regions = []
    r_start = r_end = nil
    family_tree[2].each_with_index do |cell, i|
      if cell.nil?
        r_start = i if r_start.nil?
      else
        r_end = i - 1
        regions << [r_start, r_end] if r_start && r_end
        r_start = nil
      end
    end

    return nil if regions.empty?
    regions
  end

  def self.edges_for_index(family_tree, h_index)
    family_tree[4..-1].collect do |line|
      left  = h_index
      right = h_index + 1
      left  -= 1 while line[left].nil?  && left > 0 
      right += 1 while line[right].nil? && right < line.length
      [left, right]
    end
  end

  private

end
