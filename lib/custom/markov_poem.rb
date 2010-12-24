class MarkovPoem
  TAGS_TO_STRIP = %w[BEGINNEWTEXT BEGINDELETED ENDSPAN]

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
    @lines.collect(&:display).join("<br \\>\n")
  end

  def delete_line
    @lines.slice!(rand(length))
  end

  def self.from_prog_text(pre_text, lang, options = {})
    text = options[:strip] ? pre_text.gsub(strip_tags_regex, "") : pre_text
    lines = text.split(/\sBREAK\s/).collect { |t| MarkovLine.line_from_prog_text(t, lang) }
    MarkovPoem.new(lines)
  end

  def self.strip_tags_regex
    @@strip_tags_regex_var ||= construct_strip_tags_regex
  end

  def self.construct_strip_tags_regex
    body = TAGS_TO_STRIP.collect{|t| t + '\s?' }.join("|")
    Regexp.compile(body)
  end

end
