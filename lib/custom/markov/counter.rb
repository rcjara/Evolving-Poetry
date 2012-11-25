module Markov
  class ExcludeTooManyItemsException < Exception
  end

  class Counter
    attr_reader :count, :items

    def initialize
      @count = 0
      @items = Hash.new(0)
    end

    def ==(other)
      items == other.items
    end

    def length
      @items.length
    end

    def keys
      @items.keys
    end

    def [](item)
      items[item]
    end

    def add_item(item)
      items[item] += 1
      @count += 1
    end

    def get_random_item(*excluding)
      return get_rand_from_hash(items, count) if excluding.empty?

      excluding  = Set.new(excluding)
      rand_count = count - excluding.map{ |item| self[item] }.inject(&:+)
      rand_hash  = items.reject{ |key, _| excluding.include? key }

      raise ExcludeTooManyItemsException.new if rand_hash.empty?


      get_rand_from_hash(rand_hash, rand_count)
    end

    private

    def get_rand_from_hash(hash, rand_count)
      index = rand(rand_count)

      hash.inject(0) do |running_total, (key, key_count)|
        (running_total + key_count).tap do |new_total|
          return key if new_total > index
        end
      end
    end
  end
end
