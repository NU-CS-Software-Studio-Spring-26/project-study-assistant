Feature: Log in
  As an existing student
  I want to sign in to TideTogether
  So I can access my assignments and study groups

  Background:
    Given a user account exists with email "cucumber@u.northwestern.edu" and password "password123"

  Scenario: Successful login with correct credentials
    Given I am on the login page
    When I fill in "Email" with "cucumber@u.northwestern.edu"
    And I fill in "Password" with "password123"
    And I click the "Sign In" button
    Then I should be on the assignments page

  Scenario: Failed login with wrong password
    Given I am on the login page
    When I fill in "Email" with "cucumber@u.northwestern.edu"
    And I fill in "Password" with "wrongpassword"
    And I click the "Sign In" button
    Then I should see "Invalid email or password"
