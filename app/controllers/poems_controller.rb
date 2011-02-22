class PoemsController < ApplicationController
  # GET /languages/#
  def show
    @title = "Computer Generated Poem ##{params[:id]}"
    @poem = Poem.find(params[:id])
    
    respond_to do |format|
      format.html #show.html.erb
    end
  end
end
