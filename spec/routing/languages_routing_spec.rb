require "spec_helper"

describe LanguagesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/languages" }.should route_to(:controller => "languages", :action => "index")
    end

    it "recognizes and generates #show" do
      { :get => "/languages/1" }.should route_to(:controller => "languages", :action => "show", :id => "1")
    end

  end
end
