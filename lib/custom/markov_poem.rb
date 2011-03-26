class MarkovPoem
  attr_reader :lines

  TAGS_TO_STRIP = %w[BEGINNEWTEXT BEGINALTEREDTEXT ENDSPAN FROMFIRSTPARENT FROMSECONDPARENT BEGINDELETED.*?ENDDELETED\s\S+\s?]

  def initialize(lines = [])
    @lines = lines
  end

  def length
    @lines.length
  end

  def to_prog_text
    @lines.collect(&:to_prog_text).join(" BREAK ")
  end

  def display
    @lines.collect(&:display).join("\n")
  end
  
  def undeleted_lines
    @lines.inject(0) do |sum, line|
      line.deleted? ? sum : sum + 1
    end
  end

  #####################
  # Evolution methods #
  #####################
  
  def mutate!(lang)
    max_mutate_num = undeleted_lines > 1 ? 4 : 3
    case rand(max_mutate_num)
    when 0
      add_line!(lang)
    when 1
      alter_a_tail!(lang)
    when 2
      alter_a_front!(lang)
    when 3
      delete_line!
    end
  end

  def add_line!(lang)
    new_line = lang.gen_line
    new_line.mark_as_new!

    index = rand(length + 1)
    @lines.insert(index, new_line)
  end

  def delete_line!
    orig_undeleted_lines = undeleted_lines
    return nil if orig_undeleted_lines < 2
    while undeleted_lines == orig_undeleted_lines
      line = @lines[rand(length)]
      line.mark_as_deleted! unless line.deleted?
    end
  end

  def alter_a_tail!(lang)
    alter!(lang, :alter_tail!)
  end

  def alter_a_front!(lang)
    alter!(lang, :alter_front!)
  end

  def alter!(lang, method = :alter_front!)
    success = false
    attempts = 0

    until success || attempts > Constants::MAX_ALTERING_ATTEMPTS
      line = @lines[rand(@lines.length)]
      success = line.send(method, lang)
      attempts += 1
    end
  end

  def sexually_reproduce_with(other_poem, lang)
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
        which_tag_array << true unless new_lines[-1] =~ /^BEGINDELETED.*?ENDDELETED\s\S+\s?$/
      else
        new_lines << other_lines.slice!(0)
        which_tag_array << false unless new_lines[-1] =~ /^BEGINDELETED.*?ENDDELETED\s\S+\s?$/
      end
    end
    #add any lines left to the poem
    new_lines += self_lines + other_lines
    which_tag_array += ([true] * self_lines.length) + ([false] * other_lines.length)

    new_poem = self.class.from_prog_text(new_lines.join(" BREAK "), lang, :strip => true)

    #mark which lines came from which parent
    which_tag_array.each_with_index do |first_parent, i| 
      if first_parent
        new_poem.lines[i].mark_as_from_first_parent!
      else
        new_poem.lines[i].mark_as_from_second_parent!
      end
    end

    new_poem
  end

  def half_lines
    indices = (0...length).to_a.shuffle[0...(length / 2)].sort
    prog_lines = to_prog_text.split(/ BREAK /)
    indices.collect{ |i| prog_lines[i] }
  end


  #################
  # Class Methods #
  #################

  def self.from_prog_text(pre_text, lang, options = {})
    text = options[:strip] ? strip_tags(pre_text) : pre_text
    lines = text.split(/\sBREAK\s/).collect { |t| MarkovLine.line_from_prog_text(t, lang) }
    MarkovPoem.new(lines)
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
    @@strip_tags_regex_var ||= construct_strip_tags_regex
  end

  def self.construct_strip_tags_regex
    body = TAGS_TO_STRIP.collect{|t| t + '\s?' }.join("|")
    Regexp.compile(body)
  end

end
