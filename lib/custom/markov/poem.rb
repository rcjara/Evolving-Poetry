module Markov
  class Poem
    attr_reader :lines

    TAGS_TO_STRIP = %w[BEGINNEWTEXT BEGINALTEREDTEXT ENDSPAN FROMFIRSTPARENT FROMSECONDPARENT BEGINDELETED.*?ENDDELETED\s\S+\s?]

    def initialize(lines = [])
      @lines = lines
    end

    def length
      lines.length
    end

    def to_prog_text
      lines.collect(&:to_prog_text).join(" BREAK ")
    end

    def display
      lines.collect(&:display).join("\n")
    end

    def undeleted_lines
      lines.inject(0) do |sum, line|
        line.deleted? ? sum : sum + 1
      end
    end

    #####################
    # Evolution methods #
    #####################

    def mutate(generator)
      max_mutate_num = undeleted_lines > 1 ? 4 : 3
      case rand(max_mutate_num)
      when 0
        add_line(generator)
      when 1
        alter_a_tail(generator)
      when 2
        alter_a_front(generator)
      when 3
        delete_line
      end
    end

    def add_line(generator)
      new_line = generator.generate_line.mark_as_new

      i = rand(length + 1)

      Poem.new(lines[0, i] + [new_line] + lines[i, length - i])
    end

    def delete_line
      return nil if undeleted_lines < 2

      deletable_indices = lines.zip(0..length)
                               .reject { |line, _| line.deleted? }
                               .map    { |_, i| i }

      i = deletable_indices.sample
      new_lines = lines.dup
      new_lines[i] = new_lines[i].mark_as_deleted

      Poem.new(new_lines)
    end

    def alter_a_tail(generator)
      alter(generator, :alter_line)
    end

    def alter_a_front(generator)
      alter(generator, :alter_beginning)
    end

    def alter(generator, method = :alter_beginning)
      attempt = 0
      new_line = Generator::NoAvailableIndicesForAltering
      while new_line == Generator::NoAvailableIndicesForAltering &&
            attempt < Constants::MAX_ALTERING_ATTEMPTS
        attempt    += 1
        line_index = rand(length)
        line       = lines[line_index]
        new_line   = generator.send(method, line)
      end

      return self if new_line == Generator::NoAvailableIndicesForAltering

      new_lines = lines.dup
      new_lines[line_index] = new_line
      Poem.new(new_lines)
    end

    def sexually_reproduce_with(other_poem, language)
      self_lines = half_lines
      other_lines = other_poem.half_lines
      prob = self_lines.length
      out_of = prob + other_lines.length
      new_lines = []
      which_tag_array = []

      #randomly start stacking the lines on top of each other
      while self_lines.length > 0 && other_lines.length > 0
        if rand(out_of) < prob
          new_lines << self_lines.slice!(0)
          which_tag_array << true
        else
          new_lines << other_lines.slice!(0)
          which_tag_array << false
        end
      end
      #add any lines left to the poem
      new_lines += self_lines + other_lines
      which_tag_array += ([true] * self_lines.length) + ([false] * other_lines.length)

      #mark which lines came from which parent
      marked_lines = new_lines.zip(which_tag_array)
                              .collect do |line, from_first_parent|
        if from_first_parent
          line.mark_as_from_first_parent
        else
          line.mark_as_from_second_parent
        end
      end

      Poem.new(marked_lines)
    end

    def half_lines(include_deleted = false)
      potential_lines = if include_deleted
        lines
      else
        lines.reject(&:deleted?)
      end

      potential_indices = (0...potential_lines.length).to_a
      indices           = potential_indices.sample(length / 2).sort
      indices.collect{ |i| potential_lines[i] }
    end


    #################
    # Class Methods #
    #################

    def self.new_from_prog_text(pre_text, language, options = {})
      text = options[:strip] ? strip_tags(pre_text) : pre_text
      lines = text.split(/\sBREAK\s/)
        .collect { |t| Line.new_from_prog_text(t, language) }
        .reject(&:empty?)
      Poem.new(lines)
    end

    def self.strip_tags(text)
      new_text = text.gsub(strip_tags_regex, "")
      #strip out leading breaks
      new_text.gsub!(/^\s?BREAK\s?/, "")
      #strip out trailing breaks
      new_text.gsub!(/\s?BREAK\s?$/, "")
      #strip out consecutive breaks
      nil while new_text.gsub!(/BREAK\sBREAK/, "BREAK")

      new_text
    end

    def self.strip_tags_regex
      @@strip_tags_regex ||= construct_strip_tags_regex
    end

    def self.construct_strip_tags_regex
      body = TAGS_TO_STRIP.collect{|t| t + '\s?' }.join("|")
      Regexp.compile(body)
    end

  end
end
