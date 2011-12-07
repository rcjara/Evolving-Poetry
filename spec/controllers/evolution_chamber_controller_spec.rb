require 'spec_helper'

describe EvolutionChamberController do
  before(:each) do
    @author, @work, @language = author_work_language_combo
    @poem1 = @language.gen_poem!
    @poem2 = @language.gen_poem!
  end

  describe "GET #show" do
    it "should be a success" do
      get :show, id: @language.id
      response.should be_success
    end
  end

  describe "GET #random" do
    it "should redirect to a valid evolution chamber" do
      get :random
      response.should redirect_to(evolution_chamber_path(@language.id))
    end
  end

  describe "POST #vote" do
    before(:each) do
      @params = {:vote_for => @poem1.id, :vote_against => @poem2.id}
    end

    it "should redirect to show" do
      post :vote, @params
      response.should redirect_to(evolution_chamber_path(@language.id))
    end

    it "poem1 should have 1 vote for" do
      post :vote, @params
      @poem1.reload
      @poem1.votes_for.should == 1
      @poem1.votes_against.should == 0
    end

    it "poem2 should have 1 vote for" do
      post :vote, @params
      @poem2.reload
      @poem2.votes_for.should == 0
      @poem2.votes_against.should == 1
    end

  end


end
