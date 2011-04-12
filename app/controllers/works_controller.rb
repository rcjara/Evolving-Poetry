class WorksController < ApplicationController
  def show
    @work = Work.find(params[:id])
    @title = @work.title
    raise ActiveRecord::RecordNotFound unless @work.author_visible

    respond_to do |format|
        format.html # show.html.erb
    end
  end
end
