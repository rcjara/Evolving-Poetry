class MarkovPoem
  TAGS_TO_STRIP = %w[BEGINNEWTEXT ENDSPAN BEGINDELETED.*?ENDSPAN\s\S+\s?]

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
    @lines.collect(&:display).join("<br />\n")
  end

  def delete_line
    @lines.slice!(rand(length))
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

  def add_line!(lang)
    new_line = lang.gen_line
    new_line.mark_as_new!

    index = rand(length + 1)
    if index == length
      @lines << new_line
    else
      @lines.insert(index, new_line)
    end
  end

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
