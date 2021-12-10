class CreateAlertRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :alert_requests do |t|
      t.string :uid, null: false, index: true
      t.integer :partner_id, index: true

      t.string :first
      t.string :middle
      t.string :last
      t.date :date_of_birth
      t.string :email, index: true
      t.string :phone
      t.string :phone_type

      t.string :address
      t.string :city
      t.integer :state_id, index: true
      t.string :zip

      t.boolean :opt_in_email
      t.boolean :opt_in_sms
      t.boolean :partner_opt_in_email
      t.boolean :partner_opt_in_sms

      t.boolean :javascript_disabled, null: false, default: false
      t.string :tracking_source
      t.string :tracking_id

      t.string :original_survey_question_1
      t.string :original_survey_question_2
      t.string :survey_answer_1
      t.string :survey_answer_2

      t.timestamps
    end
  end
end
