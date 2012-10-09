module FamilyTree
  class Compressor
    #This is a module written in the functional style.
    #It assumes properly formed family trees ---with_lines---.
    #It compresses family trees so that they don't have long
    #stretches of '-','-','-' unless absolutely necessary.

    def self.compress(family_tree)
      Compressor.new(family_tree).result
    end

    def initialize(family_tree)
      @original_tree = duplicate_tree(family_tree)
    end

    def result
      @result ||= compress
    end

    def to_s
      Viewer.display(result)
    end

    private

    def edges_for_index(h_index)
      # start with the fifth line, because five lines are necessary
      # to do any compression
      @original_tree[4..-1].select.with_index{|_, i| i % 2 == 0 }
        .collect do |line|
          left  = h_index
          right = h_index + 1
          left  -= 1 while line[left].nil?  && left > 0
          right += 1 while line[right].nil? && right < 2 * line.length
          [left, right]
      end
    end

    def compress
      new_tree = @original_tree.collect{ |line| line.dup } # array of arrays

      # there is nothing to
      # compress until the tree has 3 real lines of poems and
      # 2 more lines showing the relations between the lines
      return new_tree if new_tree.length < 3
      return new_tree unless blank_regions


      #work right to left
      blank_regions.reverse.each do |region|
        region_length = region[1] - region[0] + 1
        edges = edges_for_index(region[1])
        slide_length = edges.inject(region_length) do |min, edge|
          edge_gap = edge[1] - edge[0] - 1
          min < edge_gap ? min : edge_gap
        end

        next if slide_length == 0

        new_tree = Compressor.slide(new_tree, region, edges, slide_length)
      end

      Compressor.pad_short_lines_with_nils(new_tree)
    end

    def duplicate_tree(tree)
      tree.collect { |line| line.dup }
    end

    def blank_regions
      @blank_regions ||= identify_blank_regions
    end

    def identify_blank_regions
      return nil unless @original_tree.length > 3 #there is nothing to
        # compress until the tree has 3 real lines (+ 2 lines showing
        # relations)
      regions = []
      r_start = r_end = nil
      last_index = @original_tree[2].length - 1
      @original_tree[2].each_with_index do |cell, i|
        if cell.nil? && i < last_index
          r_start = i if r_start.nil?
        elsif i == last_index && cell.nil?
          regions << if r_start
            [r_start, last_index]
          else
            [last_index, last_index]
          end
        else
          r_end = i - 1
          regions << [r_start, r_end] if r_start && r_end
          r_start = nil
        end
      end

      return nil if regions.empty?
      regions
    end

    def self.pad_short_lines_with_nils(tree)
      width = tree.inject(tree[0].length) do |max, line|
        max > line.length ? max : line.length
      end
      tree.collect do |line|
        line + [nil] * (width - line.length)
      end
    end

    def self.slide(tree, region, edges, slide_length)
      tree.collect.with_index do |line, i|
        if i < 3
          line.slice!(region[0], slide_length)
        else
          # (i - 3) is because the edges only start after the 4th line
          # / 2 is because the edges skip the non-poem lines
          # [0] is to acess the left edge
          # + 1 is to get the first nil space
          cut_index = edges[(i - 3) / 2][0] + 1
          line.slice!(cut_index, slide_length)
        end

        line
      end
    end
  end
end
