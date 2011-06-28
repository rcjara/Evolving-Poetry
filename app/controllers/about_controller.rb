class AboutController < ApplicationController
  def index
    @title = "About"
  end

  def quick_evolution
    @title = "About Quick Evolution"
  end

  def points
    @title = "About Points"
  end
end
