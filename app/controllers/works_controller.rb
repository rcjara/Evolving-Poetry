class WorksController < ApplicationController
  def show
    @work = Work.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end
end
