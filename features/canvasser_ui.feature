Feature: Canvasser UI
  So that registrations can be attributed to a canvassing shift
  As a canvasser
  I want to start a new canvassing on my browser

    @passing
    Scenario: Canvasser Landing Page
      When I go to the start shift page
      Then I should not see the canvassing notice bar
      And I should see "Canvasser Web Portal"
      And I should see "Enter Partner ID"
      And I should see a field for "partner"

    @passing
    Scenario: Select Partner
      Given the following partner exists:
        | id  | name           | organization        |
        | 123 | Partner Name 2 | Organization Name 2 |
      And the following partner exists:
        | id  | name           | organization        |
        | 124 | Partner Name 3 | Organization Name 3 |
      When I go to the start shift page
      And I fill in "partner" with "123"
      And I click "Next"
      Then I should be on the shift creation page
      And I should see "Start New Canvassing Shift for Organization Name 2"
      And the "#partner_id" hidden field should be "123"

    @passing
    Scenario: Invalid Partner
      Given the following partner exists:
        | id  | name           | organization        |
        | 123 | Partner Name 2 | Organization Name 2 |
      And the following partner exists:
        | id  | name           | organization        |
        | 124 | Partner Name 3 | Organization Name 3 |
      When I go to the start shift page
      And I fill in "partner" with "999"
      And I click "Next"
      Then I should be on the start shift page
      And I should see "Partner 999 not available for canvassing shifts"

    @passing
    Scenario: Create Shift Required Fields
      Given the following partner exists:
        | id  | name           | organization        |
        | 123 | Partner Name 2 | Organization Name 2 |
      When I go to the shift creation page for partner="123"
      And I click "Start Shift"
      Then the "#partner_id" hidden field should be "123"
      And the "First Name" field should be required
      And the "Last Name" field should be required
      And the "Phone" field should be required
      And the "Email" field should be required
      And the "Location" field should be required

    @passing
    Scenario: Create Shift Formatted Fields
      Given the following partner exists:
        | id  | name           | organization        |
        | 123 | Partner Name 2 | Organization Name 2 |
      When I go to the shift creation page for partner="123"
      And I fill in "Phone" with "123"
      And I fill in "Email" with "abc"
      And I click "Start Shift"
      Then the "#partner_id" hidden field should be "123"
      And the "Phone" field should have a format error
      And the "Email" field should have a format error

    @passing
    Scenario: Create Shift
      Given the following partner exists:
        | id  | name           | organization        |
        | 123 | Partner Name 2 | Organization Name 2 |
      When I go to the shift creation page for partner="123"
      And I fill in "First Name" with "Test"
      And I fill in "Last Name" with "Canvasser"
      And I fill in "Phone" with "123-123-1234"
      And I fill in "Email" with "abc@def.ghi"
      And I select "Default Location" from "Location"
      And I click "Start Shift"
      Then I should be on the shift status page
      And I should see "0 completed registration(s)"
      And I should see "0 via paper"
      And I should see "0 via api"
      And I should see "0 abandoned registration(s)"
      And I should see a button for "Start new registration"
      And I should see a URL for starting a registartion for that shift
      And I should see a button for "End Shift"

    @passing
    Scenario: Register via Shift
      Given that I started a new shift for partner="123"
      When I go to the shift status page
      Then I should see "0 completed registration(s)"
      And I follow "Start new registration"
      And show the page
      Then I should be on a new registration page for partner="123"
      And I should see the canvassing notice bar
      And I fill in "Email" with "test@rtv.org"
      And I fill in "ZIP Code" with "19000"
      And I click "Next"
      Then I should see "Your Basic Info"
      And I should see the canvassing notice bar

    @passing
    Scenario: Complete shift registration via paper
      Given that I started a new shift for partner="123"
      When I complete a PA paper registration for that shift
      And I go to the download page
      Then I should see the canvassing notice bar with a link to the shift status page

    @passing
    Scenario: Complete shift registration via API
      Given that I started a new shift for partner="123"
      When I complete a PA online registration for that shift
      And I go to the state registrant finish page
      Then I should see the canvassing notice bar with a link to the shift status page

    @passing
    Scenario: Complete shift registration via paper due to API error
      Given that I started a new shift for partner="123"
      When I complete a PA paper fallback registration for that shift
      And I go to the download page
      Then I should see the canvassing notice bar with a link to the shift status page

    @passing
    Scenario: Canvassing status
      Given that I started a new shift for partner="123"
      And I complete "3" registrations
      And I start "2" abandoned
      When I go to the shift status page
      Then I should see "3 completed registration(s)"
      And I should see "2 abandoned registration(s)"

    @passing
    Scenario: End Shift
      Given that I started a new shift for partner="123"
      And I complete "3" registrations
      And I start "2" abandoned
      When I go to the shift status page
      And I follow "End Shift"
      Then I should be on the start shift page
      And I should see "Test Canvasser clocked out"
      
    @passing
    Scenario: Canvassing Link
      Given the following partner exists:
        | id  | name           | organization        |
        | 123 | Partner Name 2 | Organization Name 2 |
      And the followig canvassing shift exists:
        | partner_id | shift_external_id |
        | 123        | web-123           |
      When I go to the new registration page for that shift
      Then I should be on a new registration page for partner="123"
      And I should see the canvassing notice bar
    
    @passing
    Scenario: Complete shift registration via paper
      Given the following partner exists:
        | id  | name           | organization        |
        | 123 | Partner Name 2 | Organization Name 2 |
      And the followig canvassing shift exists:
        | partner_id | shift_external_id |
        | 123        | web-123           |
      When I complete a PA paper registration for that shift
      And I go to the download page
      Then I should see the canvassing notice bar
      And I should not see the canvassing notice bar with a link to the shift status page