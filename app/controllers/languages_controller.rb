class LanguagesController < ApplicationController
  # GET /languages
  def index
    @languages = Language.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /languages/1
  def show
    @language = Language.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

end
