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

When /^I visit a poem$/ do
  visit poem_path(Poem.first)
end

Then /^the page should load without error$/ do
  expect(page.status_code).to eq 200
end
