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

    describe "username login" do
      before(:each) do
        @user = Factory(:user)
        @attr = {:username => "Example User", :password => "foobar"}
      end

      it "should sign the user in and show that signed_in? == true" do
        post :create, :user_session => @attr
        controller.should be_signed_in
      end

      it "should sign the user in and show that the right user is signed in" do
        post :create, :user_session => @attr
        controller.current_user.should == @user
      end
    end
    
    describe "email login" do
      before(:each) do
        @user = Factory(:user)
        @attr = {:username => "raul.c.jara@gmail.com", :password => "foobar"}
      end

      it "should sign the user in and show that signed_in? == true" do
        post :create, :user_session => @attr
        controller.should be_signed_in
      end

      it "should sign the user in and show that the right user is signed in" do
        post :create, :user_session => @attr
        controller.current_user.should == @user
      end
    end
  end
end
