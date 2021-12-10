require 'rails_helper'

RSpec.feature 'Alert Request' do

  let(:answers) do
    {
      partner_id: Partner::DEFAULT_ID,
      first: 'First',
      middle: 'Middle',
      last: 'Last',
      date_of_birth: Date.new(2000, 1, 2),
      email: 'email@mail.com',
      phone: '123-123-1234',
      phone_type: 'mobile',
      address: 'Address',
      city: 'City',
      state_id: 2,
      zip: '99801',
      tracking_source: '',
      tracking_id: '',
      original_survey_question_1: 'What school did you go to?',
      original_survey_question_2: 'What is your favorite musical group?',
      survey_answer_1: 'answer 1',
      survey_answer_2: 'answer 2',
      opt_in_email: true,
      opt_in_sms: nil,
      partner_opt_in_email: nil,
      partner_opt_in_sms: nil,
    }
  end

  def fill_form
    fill_in 'First', with: 'First'
    fill_in 'Middle', with: 'Middle'
    fill_in 'Last', with: 'Last'
    fill_in 'alert_request_date_of_birth_month', with: '1'
    fill_in 'alert_request_date_of_birth_day', with: '2'
    fill_in 'alert_request_date_of_birth_year', with: '2000'
    fill_in 'Address', with: 'Address'
    fill_in 'City', with: 'City'
    fill_in 'Zip', with: '99801'
    fill_in 'Email', with: 'email@mail.com'
    fill_in 'Phone', with: '123-123-1234'
    fill_in 'What school did you go to?', with: 'answer 1'
    fill_in 'What is your favorite musical group?', with: 'answer 2'
  end

  scenario 'html form all fields', js: true do
    visit '/pledge'
    fill_form

    find(:button, text: 'Sign me up!').click
    expect(page).to have_content('Thank you for joining us.')

    expect(AlertRequest.last).to have_attributes(
      answers.merge(javascript_disabled: false)
    )
  end

  scenario 'no js', js: false do
    visit '/pledge'
    fill_form

    find(:button, text: 'Sign me up!').click
    expect(page).to have_content('Thank you for joining us.')

    expect(AlertRequest.last).to have_attributes(
      answers.merge(javascript_disabled: true)
    )
  end
end
