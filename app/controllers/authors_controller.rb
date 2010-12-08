class AuthorsController < ApplicationController
  # GET /authors
  def index
    @authors = Author.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    @author = Author.find(params[:id])

    respond_to do |format|
      format.html # index.html.erb
    end
  end
end
