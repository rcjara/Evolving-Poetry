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
