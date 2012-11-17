module Markov
  class UnsupportedTagError < Exception
  end

  class WordDisplayer
    SUPPORTED_TAGS = {
      beginnewtext:     %{<span class="new-text">},
      beginalteredtext: %{<span class="altered-text">},
      begindeleted:     %{<span class="deleted-text">},
      fromfirstparent:  %{<span class="from-first-parent">},
      fromsecondparent: %{<span class="from-second-parent">},

      endspan:          ->(dw) { dw.insert -1, %{</span>} },
      enddeleted:       ->(dw) { dw.insert -1, %{</span>} },

      shout:            ->(dw) { dw.upcase! }
    }

    attr_reader :word, :tags

    def initialize(word, tags = [])
      @word = word
      @tags = tags
    end

    def display(new_sentence = false, use_tags = true)
      word.identifier.to_s.dup.tap do |dw|
        dw.capitalize!    if word.proper? || new_sentence
        dw.insert(0, ' ') unless word.punctuation?

        tags.each { |tag| execute_tag(tag, dw) } if use_tags
      end
    end

    def execute_tag(tag, display_word)
      tag_action = SUPPORTED_TAGS[tag]
      raise UnsupportedTagError.new("No such tag: #{tag}") unless tag_action

      if tag_action.is_a?(String)
        display_word.insert(0, tag_action)
      else
        tag_action.call(display_word)
      end
    end

    def to_prog_text
      (tags.collect{ |t| t.to_s.upcase } + [word.identifier.to_s])
        .join(' ')
    end

    def num_chars
      display(false, false).length
    end

    def add_tag(tag)
      tags << tag
    end

    def has_tag?(tag)
      tags.include? tag
    end

    def method_missing(meth, *args, &block)
      if word.respond_to?(meth)
        word.send(meth)
      else
        super
      end
    end

    def respond_to?(meth)
      if word.respond_to?(meth)
        true
      else
        super
      end
    end
  end
end
