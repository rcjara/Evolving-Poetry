require 'spec_helper'

describe "pages/home.html.erb" do

  describe "when a user is signed in" do
    before(:each) do
      view.should_receive(:signed_in?).and_return(true)
    end


    it "should render properly" do
      render
    end

    it "should render properly with the layout included" do
      render, :layout 'application'
    end

  end

  describe "when a user is not signed in" do
    before(:each) do
      view.should_receive(:signed_in?).and_return(false)
    end


    it "should render properly" do
      render
    end

    it "should include a link to sign up" do
      render
      rendered.should =~ /Sign up/
    end

    it "should include a link to log in" do
      render
      rendered.should =~ /Log in/
    end
  end


end
