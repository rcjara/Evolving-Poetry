require 'spec_helper'

describe "languages/show.html.erb" do
  before(:each) do
    @language = assign(:language, stub_model(Language,
      :name => "Name",
      :total_votes => 1,
      :max_poems => 1,
      :poems_sexually_reproduced => 1,
      :poems_asexually_reproduced => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(/Name/)
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(/1/)
  end
end
