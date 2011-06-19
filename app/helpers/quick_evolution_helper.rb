module QuickEvolutionHelper
  def form_to_continue(poem)
    form_tag(:controller => :quick_evolution, :action => :continue, :method => :post) do
      submit_tag("Continue with This Poem") +
      hidden_field_tag('prog_text', poem.programmatic_text)
    end
  end
end
