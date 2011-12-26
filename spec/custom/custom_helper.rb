module CustomHelper
  class PoemStub
    attr_reader :parent, :second_parent_id

    def initialize(parent = nil, second_parent_id = nil)
      @parent = parent
    end

    def inspect
      "<p>"
    end
  end
end
