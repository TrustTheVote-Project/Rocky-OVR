Feature: Log in
  A partner
  Should be able to customize 

  Background:
    Given I registered with "bullwinkle/password"
    And I go to the login page
    And I log in as "bullwinkle/password"

  
  Scenario: Editable Subject Lines for emails

  Scenario: Review branding
    Given that partner's assets do not exist
    When I go to the partner branding page
    Then I should see "Setup Custom Branding"
    Then The "css" css is "state"
      |         css |   state |
      | application | missing |
      |registration | missing |
      |     partner | missing |
    Then non-approved assets are empty
    Then approved assets are empty
