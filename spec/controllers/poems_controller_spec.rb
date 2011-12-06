require 'spec_helper'

describe PoemsController do
  before(:each) do
    @author, @work, @language = author_work_language_combo
    @poem = @language.gen_poem!
  end


  describe "GET #show" do
    it "should be a success" do
      get 'show', id: @poem.id
      response.should be_success
    end
  end
end
