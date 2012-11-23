module Markov
  class Counter
    attr_reader :count, :items

    def initialize
      @count = 0
      @items = Hash.new(0)
    end

    def [](item)
      items[item]
    end

    def add_item(item)
      items[item] += 1
      @count += 1
    end
  end
end
