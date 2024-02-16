class AddSubjectToEmailTemplates < ActiveRecord::Migration[4.2]
  def change
    add_column :email_templates, :subject, :string
  end
end
