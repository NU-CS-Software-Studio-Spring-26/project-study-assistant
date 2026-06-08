Feature: Sign up
  As a Northwestern student
  I want to create a TideTogether account
  So I can track assignments and join study groups

  Scenario: Successful sign up with terms accepted
    Given I am on the sign up page
    When I fill in my registration details
    And I accept the terms of service
    And I click the "Create User" button
    Then I should be on the dashboard

  Scenario: Sign up is blocked without accepting terms
    Given I am on the sign up page
    When I fill in my registration details
    But I do not accept the terms of service
    And I click the "Create User" button
    Then I should see "must be accepted to create an account"
