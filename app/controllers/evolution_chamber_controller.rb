class EvolutionChamberController < ApplicationController
  def show
    @language = Language.find(params[:id])
    @title = "Evolution Chamber: #{@language.name}"
    @poem1, @poem2 = @language.poems_for_voting

    respond_to do |format|
      format.html
    end
  end

  def random
    redirect_to :action => :show, :id => Language.random
  end

  def vote
    @for = Poem.find(params[:vote_for])
    @against = Poem.find(params[:vote_against])

    @for.vote_for!
    @against.vote_against!

    redirect_to :action => :show, :id => @for.language
  end
end
