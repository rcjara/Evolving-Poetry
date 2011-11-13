module EvolutionChamberHelper
  def form_for_voting(poem1, poem2)
    form_tag(:controller => :evolution_chamber, :action => :vote, :method => :post) do
      hidden_field_tag('vote_for',     poem1.id) +
      hidden_field_tag('vote_against', poem2.id)
    end
  end

  def vote_for_msg(msg)
    poem = Poem.find(msg[:voted_for])
    parts = []
    parts << "You voted for " + poem_link(poem) + "."
    parts << if msg[:gave_birth]
      new_poem = Poem.find(msg[:child])
      if new_poem.second_parent
        "The poem you voted for was looking so good, it hooked up with " +
          poem_link(new_poem.second_parent) +
          " and gave birth to " +
          poem_link(new_poem) + "."
      else
        "The poem you voted for got so full of itself, it split and gave birth to " +
          poem_link(new_poem) + "."
      end
    else
      num = msg[:votes_til_birth]
      "If it gets <strong> #{pluralize(num, 'more vote')}</strong>, it will give birth to a beautiful (?) new baby poem."
    end
    parts.join("<br />").html_safe
  end

  def vote_against_msg(msg)
    poem = Poem.find(msg[:voted_against])
    parts = []
    parts << "You voted against " + poem_link(poem) + "."
    parts << if msg[:died]
      poem_link(poem) +
        " couldn't take the rejection and died. The time of death was " +
          tod_fmt(poem) +
          "."
    else
      num = msg[:votes_til_death]
      "If no one clicks on it <strong>#{pluralize(num, 'more time')}</strong>, it will die."
    end
    parts.join("<br />").html_safe
  end
end


#      if votes_til_birth <= 0
#        response[:gave_birth] = true
#        response[:child] = bear_child
#      end
#
#      response[:voted_for] = self
#      response[:save_status] = save
#      response[:votes_til_birth] = votes_til_birth
