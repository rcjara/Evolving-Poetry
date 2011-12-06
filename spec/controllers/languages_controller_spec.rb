require 'spec_helper'

describe LanguagesController do

  before(:each) do
    @author, @work, @language = author_work_language_combo
  end

  describe "GET #index" do
    it "should be a success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET #show" do
    it "should be a success" do
      get 'show', id: @language.id
      response.should be_success
    end
  end
end
