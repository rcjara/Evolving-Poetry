require 'spec_helper'

describe UserSessionsController do
  render_views

  before(:each) do
    :activate_authlogic 
  end
  
  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
  end

  describe "POST 'create'" do

    describe "invalid signin" do
      before(:each) do
        @attr = {:username => "bad@email.com", :password => "invalid" }
      end

      it "should re-render the new page" do
        post :create, :user_session => @attr
        response.should render_template('new')
      end
    end

  end
end
