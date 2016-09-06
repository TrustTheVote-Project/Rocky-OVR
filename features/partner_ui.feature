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
    Then non-approved assets are empty
    Then approved assets are empty

  Scenario: Preview changes
    Given that partner's assets do not exist
    When I go to the partner branding page
    And I should see a link for "registrant_preview"
    And Assets "not set" warning should be shown
    When I follow "registrant_preview"
    Then I should be redirected to the right preview URL

  Scenario: Preview CSS injection
    Given partner's assets exist:
      | asset                    |
      | preview/application.css  |
      | preview/registration.css |
      | preview/partner.css      |
    When I go to the partner branding page
    And I follow "Assets"
    Then non-approved assets are application.css, registration.css, partner.css
    Then approved assets are empty
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

  Scenario: Mixed assets
    Given partner's assets exist:
      | asset                    |
      | preview/application.css  |
      | preview/custom.jpg       |
      | application.css          |
    When I go to the partner branding page
    And I follow "Assets"
    Then non-approved assets are application.css, custom.jpg
    Then approved assets are application.css

  Scenario: upload asset
    Given that partner's assets do not exist
    When I go to the partner branding page
    Then non-approved assets are empty
    And approved assets are empty
    And Assets "not set" warning should be shown
    Then I attach the file at "spec/fixtures/files/partner_logo.jpg" to "partner_file"
    And I press "partner_submit"
    Then non-approved assets are partner_logo.jpg
    And approved assets are empty
    And Assets status warning is not shown
    Then changes are published
    Then reload the page
    Then non-approved assets are partner_logo.jpg
    And approved assets are partner_logo.jpg
    And Assets "not changed" warning should be shown

  Scenario: fake registrant creation
    Given partner's assets exist:
      | asset                |
      | preview/pdf_logo.jpg |
    When I go to the partner branding page
    And I follow "registrant_preview"
    And I have not set a locale
    And I fill in "Email Address" with "john.public@example.com"
    And I fill in "ZIP Code" with "94113"
    And I am 20 years old
    And I check "registrant_has_state_license"
    And I check "registrant_will_be_18_by_election"
    And I check "I am a U.S. citizen"
    And I press "registrant_submit"
    Then fake registrant is created

  Scenario: fake registrant pdf logo preview
    Given partner's assets exist:
      | asset                |
      | preview/pdf_logo.jpg |
    Given fake registrant finished registration
    Then registrant pdf includes "preview/pdf_logo.jpg"
