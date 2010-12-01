require 'spec_helper'

describe "languages/edit.html.erb" do
  before(:each) do
    @language = assign(:language, stub_model(Language,
      :new_record? => false,
      :name => "MyString",
      :total_votes => 1,
      :max_poems => 1
    ))
  end

  it "renders the edit language form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => language_path(@language), :method => "post" do
      assert_select "input#language_name", :name => "language[name]"
      assert_select "input#language_total_votes", :name => "language[total_votes]"
      assert_select "input#language_max_poems", :name => "language[max_poems]"
    end
  end
end