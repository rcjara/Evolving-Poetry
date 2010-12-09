class AuthorsController < ApplicationController
  # GET /authors
  def index
    @authors = Author.where('visible = ?', true).paginate(:page => params[:page], :order => 'last_name')

    respond_to do |format|
      format.html # index.html.erb
    end
  end
end
