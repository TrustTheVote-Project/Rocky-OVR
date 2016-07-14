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

  Scenario: Preview changes
    Given that partner's assets do not exist
    When I go to the partner branding page
    And I should see a link for "registrant_preview"
    When I follow "registrant_preview"
    Then I should be redirected to the right preview URL

  Scenario: Preview CSS injection
    Given partner's assets exist:
      | asset                    |
      | preview/application.css  |
      | preview/registration.css |
      | preview/partner.css      |
    When I go to the partner branding page
    And I follow "registrant_preview"
    Then preview/application.css should be loaded
    Then preview/registration.css should be loaded
    Then preview/partner.css should be loaded

  Scenario: Preview CSS injection partly
    Given partner's assets exist:
      | asset                    |
      | preview/registration.css |
    When I go to the partner branding page
    And I follow "registrant_preview"
    Then system application.css should be loaded
    Then preview/registration.css should be loaded
