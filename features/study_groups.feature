Feature: Study groups
  As a logged-in student
  I want to create study groups
  So I can study with other Northwestern students

  Background:
    Given I am logged in as a student

  Scenario: Successfully creating a study group
    Given I am on the new study group page
    When I fill in the study group form with valid details
    And I click the "Create Study group" button
    Then I should see "Study group was successfully created"

  Scenario: Creating a study group with profanity in the name is blocked
    Given I am on the new study group page
    When I fill in the study group form with profanity in the name
    And I click the "Create Study group" button
    Then I should see "contains inappropriate language"
