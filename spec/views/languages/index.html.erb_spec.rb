require 'spec_helper'

describe "languages/index.html.erb" do
  before(:each) do
    assign(:languages, [
      stub_model(Language,
        :name => "Name",
        :total_votes => 1,
        :max_poems => 1
      ),
      stub_model(Language,
        :name => "Name",
        :total_votes => 1,
        :max_poems => 1
      )
    ])
  end

  it "renders a list of languages" do
    render
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
