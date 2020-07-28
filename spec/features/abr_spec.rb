require 'rails_helper'

RSpec.feature 'ABR' do

  scenario 'positive end to end', js: true do
    visit '/absentee'
    fill_in 'Email Address', with: 'registrant@mail.com'
    fill_in 'ZIP Code', with: 99801
    # click_on doesn't work - we use <button> inside <a>
    find(:button, text: 'Next Step').click

    fill_in 'First Name', with: 'John'
    fill_in 'Last Name', with: 'Smith'
    fill_in 'Street number', with: 120
    fill_in 'Street name', with: '4th St'
    fill_in 'City', with: 'Juneau'

    fill_in 'abr_date_of_birth_month', with: 1
    fill_in 'abr_date_of_birth_day', with: 2
    fill_in 'abr_date_of_birth_year', with: 2000

    find(:button, text: 'Next Step').click
    expect(page).to have_content('You can request an Absentee Ballot online directly with the state of Alaska')
  end
end
