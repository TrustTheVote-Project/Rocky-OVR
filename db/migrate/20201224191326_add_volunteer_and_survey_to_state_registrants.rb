class AddVolunteerAndSurveyToStateRegistrants < ActiveRecord::Migration
  def change
    add_column :state_registrants_pa_registrants, "volunteer",                  :boolean,  default: false
    add_column :state_registrants_pa_registrants, "original_survey_question_1", :string
    add_column :state_registrants_pa_registrants, "original_survey_question_2", :string
    add_column :state_registrants_pa_registrants, "survey_answer_1",            :string
    add_column :state_registrants_pa_registrants, "survey_answer_2",            :string

    add_column :state_registrants_mi_registrants, "volunteer",                  :boolean,  default: false
    add_column :state_registrants_mi_registrants, "original_survey_question_1", :string
    add_column :state_registrants_mi_registrants, "original_survey_question_2", :string
    add_column :state_registrants_mi_registrants, "survey_answer_1",            :string
    add_column :state_registrants_mi_registrants, "survey_answer_2",            :string

    add_column :state_registrants_va_registrants, "volunteer",                  :boolean,  default: false
    add_column :state_registrants_va_registrants, "original_survey_question_1", :string
    add_column :state_registrants_va_registrants, "original_survey_question_2", :string
    add_column :state_registrants_va_registrants, "survey_answer_1",            :string
    add_column :state_registrants_va_registrants, "survey_answer_2",            :string
  end
end
