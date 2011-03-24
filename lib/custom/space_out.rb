# this is a module that, given an array filled with non-nil
# objects, and a desired size, it will space out the 
# objects in the array in an asthetically pleasing fashion,
# padding the empty space with nils.
#
# e.g. given [a, b, c], 5 => [a, nil, b, nil, c]
#
module SpaceOut
  def self.space(array, targ_len, separator = nil)
    return array if targ_len <= array.length
    if targ_len % 2 == 1
      recursive_space(array, targ_len, separator)
    else
      even_space(array, targ_len, separator)
    end
  end

  def self.recursive_space(array, targ_len, separator = nil)
    return array if targ_len <= array.length
    if array.length == 1
      last_part  = [separator] * ((targ_len - 1) / 2)
      first_part = [separator] * ((targ_len - 1) - last_part.length)
      first_part + [ array[0] ] + last_part
    else
      middle = recursive_space(array[1...-1], targ_len - 2)
      [ array[0], *middle, array[-1] ]
    end
  end

  def self.even_space(array, targ_len, separator = nil)
    objs_left   = array.length
    blanks_left = targ_len - objs_left
    ratio       = objs_left / blanks_left
    new_array   = []

    while new_array.length < targ_len && blanks_left > 0
      if objs_left / blanks_left >= ratio
        new_array << array[array.length - objs_left]
        objs_left -= 1
      else
        new_array << separator
        blanks_left -= 1
      end
    end

    new_array << array[array.length - objs_left] while 
      new_array.length < targ_len

    new_array
  end
end
