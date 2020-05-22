Feature: Canvasser UI
  
  So that registrations can be attributed to a canvassing shift
  As a canvasser
  I want to start a new canvassing on my browser
    
    Background:
      Blocks API is mocked
    
    @wip
    Scenario: Canvasser Landing Page
      Should not see notice
      Should see welcome text
      Should see partner select box

    @wip
    Scenario: Select Parter
      Given the following partner exists:
      (set IDs in )
        | name         | organization      |
        | Partner Name | Organization Name |
      When I go to the start shift page
      I should see the partner selects
      When I select partner 1
      And I click "Next"
      Then I should be on the shift creation page with the partner selected
      
    @wip
    Scenario: Create Shift Required Fields
      Given that I go to the shift creation page for partner=123
      When I click "Start Shift"
      I should see all fields are required

    @wip
    Scenario: Create Shift Formatted Fields
      Given that I go to the shift creation page for partner=123
      When I fill out the shift form
      And I fill in phone with "123"
      And I fill in email with "abc"
      And I click "Start Shift"
      Then I should see a format error for canvasser_phone
      And I should see a format error for canvasser_email


    @wip
    Scenario: Create Shift
      Given that I go to the shift creation page for partner=123
      When I fill out the shift form
      And I click "Start Shift"
      Then I should see the shift status page
      And I should see "0 registrations completed"
      And I should see "0 registrations abandoned"
      And I should see a button for "New Registration"
      And I should see a button for "End Shift"
      
    @wip
    Scenario: Register via Shift
      Given that I started a new shift
      When I go tot he shift status page
      And I click "New Registration"
      Then I should be on the new registration page
      And I should see the canvassing notice bar
      And I fill in "Email" with "test@rtv.org"
      And I fill in "Zip Code" with "19000"
      And I click "Next"
      Then I should be on the registration step 2 page
      And I should see the canvassing notice bar
    
    @wip
    Scenario: Complete shift registration
      Given that I started a new shift
      When I complete a registration for that shift
      # Should there be different versions for opted-in paper, error-paper and via API?
      I should see the canvassing notice bar with a link to the shift status page
      
    @wip
    Scenario: Canvassing status
      Given that I started a new shift with "3" complete registrations and "2" abandoned registrations
      When I go to the shift status page
      Then I should see "3 registrations completed"
      And I should see "2 registrations abandoned"
      
    @wip
    Scenario: End Shift
      Given that I started a new shift with "3" complete registrations and "2" abandoned registrations
      When I go to the shift status page
      And I click "End Shift"
      Then I should be on the start shift page
      And I should see the shift end message
      
      
    