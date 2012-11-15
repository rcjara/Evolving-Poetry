Given /^there is at least one language with poems$/ do
  work = Work.create(title: "Work", content: "This is the the content")
  author = Author.create(first_name: "Raul",
                         last_name: "Jara",
                         visible: true,
                         full_name: "Raul Jara")
  language = Language.create(name: "Test Language", active: true)
  author.works << work
  author.save!
  language.add_author! author
  language.save!
  3.times { language.gen_poem! }
end

When /^I visit to the main page$/ do
  visit root_path
end

When /^I visit a random evolution chamber$/ do
  visit evolution_chamber_random_path
end

When /^I visit a poem$/ do
  visit poem_path(Poem.first)
end

When /^I visit a work$/ do
  visit work_path(Work.first)
end

When /^I visit the languages index$/ do
  visit languages_path
end

When /^I visit the authors index$/ do
  visit authors_path
end

When /^I visit the about index$/ do
  visit about_index_path
end

When /^I visit the (.*) about page$/ do |title|
  visit about_path(title)
end

Then /^the page should load without error$/ do
  expect(page.status_code).to eq 200
end
