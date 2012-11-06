Feature: Visiting any publicly accessible page should work without throwing an error.

  Scenario: Visit the main page
    When I visit to the main page
    Then the page should load without error
