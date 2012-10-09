module CustomHelper
  class PoemStub
    attr_reader :parent, :second_parent_id

    def initialize(parent = nil, second_parent_id = nil)
      @parent = parent
      @second_parent_id = second_parent_id
    end

    def inspect
      '<p>'
    end

    def to_s
      'p'
    end
  end
end
