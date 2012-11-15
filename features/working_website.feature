Feature: Visiting any publicly accessible page should work without throwing an error.
  Background:
    Given there is at least one language with poems

  Scenario: Visit the main page
    When I visit to the main page
    Then the page should load without error

  Scenario: Visit a random evolution chamber
    When I visit a random evolution chamber
    Then the page should load without error

  Scenario:
    When I visit a poem
    Then the page should load without error

  Scenario:
    When I visit the languages index
    Then the page should load without error

  Scenario:
    When I visit the authors index
    Then the page should load without error

  Scenario:
    When I visit the authors index
    Then the page should load without error

  Scenario:
    When I visit a work
    Then the page should load without error

  Scenario:
    When I visit the about index
    Then the page should load without error

  Scenario:
    When I visit the markov-chains about page
    Then the page should load without error

