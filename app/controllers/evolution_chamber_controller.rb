class EvolutionChamberController < ApplicationController
  def show
    @language = Language.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @language.active
    @title = "Evolution Chamber: #{@language.name}"
    @poem1, @poem2   = @language.poems_for_voting

    @voting_response = flash[:voting_response]

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

    for_response     = @for.vote_for!
    against_response = @against.vote_against!

    flash[:voting_response] = for_response.merge(against_response)
    award_point!

    redirect_to :action => :show, :id => @for.language
  end
end
