Feature: Ineligible
  As a registrant
  I want to be denied when I am ineligible
  In order to move on

    @passing
    Scenario: state doesn't register
     Given I go to a new registration page
       And I enter valid data for step 1
       But I live in North Dakota
      When I press "registrant_submit"
      Then I should see "North Dakota does not have voter registration"
       And I should see "North Dakota"
      When I follow "Return"
       And I live in California
       And I press "registrant_submit"
      Then I should see "Name"
       And I should see "Address"

    @passing
    Scenario: not citizen
      Given I have completed step 1
      When I go to the step 2 page
      And I enter valid data for step 2
      And I uncheck "I am a U.S. citizen"
      When I press "registrant_submit"
      Then I should see "You must be a US citizen"
      When I check "I am a U.S. citizen"
      And I press "registrant_submit"
      Then I should not see "You must be a US citizen"

    @passing
    Scenario: multiple reasons on same page
     Given I go to a new registration page
       And I enter valid data for step 1
       And I live in North Dakota
      When I press "registrant_submit"
      Then I should see "North Dakota does not have voter registration"
      When I follow "Return"
       And I live in California
       And I press "registrant_submit"
      Then I should see "Name"
      And I should see "Address"

    @wip
    Scenario: under 18 but old enough
     Given I go to a new registration page
       And I enter valid data for step 1
       But I am 15 years old
      When I press "registrant_submit"
      Then I should see "you aren't 18 yet"
      When I press "Keep Going"
      Then I should see "Personal Information"

    @wip
    Scenario: under 18 and wants reminder
     Given I go to a new registration page
       And I enter valid data for step 1
       But I am 15 years old
      When I press "registrant_submit"
      Then I should see "you aren't 18 yet"
      When I press "Remind Me Later"
      Then I should see "You're on the list!"
