class PagesController < ApplicationController
  def home
    @title = "Home"
  end

  def about
    @title = "About"
  end

  def about_quick_evolution
    @title = "About Quick Evolution"
  end

end
