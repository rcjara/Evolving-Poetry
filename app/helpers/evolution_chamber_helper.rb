module EvolutionChamberHelper
  def form_for_voting(poem1, poem2)
    form_tag(:controller => :evolution_chamber, :action => :vote, :method => :post) do
      hidden_field_tag('vote_for',     poem1.id) +
      hidden_field_tag('vote_against', poem2.id)
    end
  end
end
