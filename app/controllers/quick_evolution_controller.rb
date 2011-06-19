class QuickEvolutionController < ApplicationController
  def new
    @language = Language.find(params[:id])

    @orig_poem, @other_poems = @language.quick_evolution_poems

    render "new"
  end

  def continue
    @language = Language.find(params[:id])

    @orig_poem, @other_poems = @language.quick_evolution_poems(
        @language.from_prog_text(params[:prog_text]) )

    render "new"
  end
end
