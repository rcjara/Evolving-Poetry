require 'spec_helper'

describe WorksController do

  before(:each) do
    @author, @work, @language = author_work_language_combo
  end

  describe "GET #show" do
    it "should be a success" do
      get :show, id: @work.id
      response.should be_success
    end
  end

end
