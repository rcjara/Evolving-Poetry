class WorksController < ApplicationController
  def show
    @title = @work.title
    @work = Work.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @work.author.visible

    respond_to do |format|
        format.html # show.html.erb
    end
  end
end
