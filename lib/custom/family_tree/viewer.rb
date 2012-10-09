module FamilyTree
  class Viewer
    def self.display(family_tree)
      family_tree.collect do |line|
        line.collect { |item| display_item(item) }.join(" ")
      end.join("\n")
    end

    private

    def self.display_item(item)
      if item.nil?
        '.'
      elsif item.class == Poem
        'p'
      else
        item.to_s
      end
    end
  end
end
