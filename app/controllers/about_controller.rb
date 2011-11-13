class AboutController < ApplicationController
  def index
    @title = "About"
  end

  def show
    page = params[:id]

    render "about/#{page}"
  end
end
