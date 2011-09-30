class LanguagesController < ApplicationController
  # GET /languages
  def index
    @title     = "Languages"
    @languages = Language.visible.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    @language = Language.find(params[:id])

    @title    = @language.name
    @poems    = @language.poems_by(params[:sorting]).paginate(:page => params[:page])

    respond_to do |format|
      format.json { render :json => @language.markov }
      format.html { ActiveRecord::RecordNotFound unless @language.visible; render }
    end
  end

end
