class LanguagesController < ApplicationController
  # GET /languages
  def index
    @languages = Language.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def evolution_chamber
    @languge = Language.find(params[:id])
    @poems = @language.poems.where("alive = ?", true)
    @poem1 = @poems[rand(@poems.length)]
    @poem2 = @poem1
    while @poem1 == @poem2
      @poem2 = @poems[rand(@poems.length)]
    end

    respond_to do |formate|
      format.html
    end
  end
end
