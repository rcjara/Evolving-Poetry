Feature: Visiting any publicly accessible page should work without throwing an error.
  Background:
    Given there is at least one language with poems

  Scenario: Visit the main page
    When I visit to the main page
    Then the page should load without error

  Scenario:
    When I visit a poem
    Then the page should load without error

