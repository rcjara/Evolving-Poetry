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
      lines.inject(0) { |sum, line| line.deleted? ? sum : sum + 1 }
    end

    def insert_line_at(new_line, i)
      Poem.new(lines[0...i] + [new_line] + lines[i..-1])
    end

    def replace_line_at(new_line, i)
      Poem.new(lines[0...i] + [new_line] + lines[(i + 1)..-1])
    end

    def unaltered_indices
      @unaltered_indices ||=
        lines.map.with_index { |line, i| [line.to_prog_text, i] }
                 .reject     { |line, i| line =~ self.class.strip_tags_regex }
                 .map        { |_, i| i }
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
