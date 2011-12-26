class ChildrenWithFathers
  def initialize(children)
    @children = children
  end

  def bastards
    @children.select { |child| child.second_parent_id.nil? }
  end

  def by_father
    (Hash.new { [] }).tap do |h|
      @children.each do |child|
        f_id = child.second_parent_id
        next if f_id.nil?

        h[f_id] += [child]
      end
    end
  end
end
