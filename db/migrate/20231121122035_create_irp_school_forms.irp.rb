# This migration comes from irp (originally 20231120120912)
class CreateIrpSchoolForms < ActiveRecord::Migration[7.0]
  def change
    create_table :irp_school_forms do |t|
      t.boolean :best_person
      t.string :first_name
      t.string :last_name
      t.string :email_address
      t.string :position
      t.boolean :employment_duration
      t.boolean :employment_start_date
      t.boolean :subject_taught
      t.uuid :claim_id
      t.datetime :submitted_at

      t.timestamps
    end
  end
end
