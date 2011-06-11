class LanguagesController < ApplicationController
  before_filter :require_user,   :only => [:show]

  # GET /languages
  def index
    @title     = "Languages"
    @languages = Language.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    @language = Language.find(params[:id])
    @title    = @language.name
    @poems    = @language.poems_by(params[:sorting]).paginate(:page => params[:page])
  end


end
