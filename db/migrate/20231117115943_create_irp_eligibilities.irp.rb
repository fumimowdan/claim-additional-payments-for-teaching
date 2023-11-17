# This migration comes from irp (originally 20231117103401)
class CreateIrpEligibilities < ActiveRecord::Migration[7.0]
  def change
    create_table :irp_eligibilities, id: :uuid do |t|
      t.uuid :school_id
      t.integer :award_amount

      # eligibility fields
      t.string :application_route
      t.boolean :one_year
      t.boolean :state_funded_secondary_school
      t.string :subject
      t.string :visa_type
      t.date :date_of_entry
      t.date :start_date

      t.timestamps
    end
  end
end
