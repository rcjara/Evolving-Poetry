class LanguagesController < ApplicationController
  # GET /languages
  def index
    @languages = Language.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
    end
  end

end
