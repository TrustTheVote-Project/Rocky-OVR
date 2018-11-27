class CreateSesNotifications < ActiveRecord::Migration
  def change
    create_table :ses_notifications do |t|
      t.text :request_params
      t.timestamps null: false
    end
  end
end
