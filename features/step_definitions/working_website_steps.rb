When /^I visit to the main page$/ do
  visit root_path
end

Then /^the page should load without error$/ do
  expect(page.status_code).to eq 200
end
