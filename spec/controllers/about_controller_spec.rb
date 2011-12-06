require 'spec_helper'

describe AboutController do
  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'about/markov-chains" do
    it "should be successful" do
      get 'show', id: 'markov-chains'
      response.should be_success
    end
  end

  describe "GET 'about/points" do
    it "should be successful" do
      get 'show', id: 'points'
      response.should be_success
    end
  end

end
