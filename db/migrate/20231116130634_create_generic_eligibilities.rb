class CreateGenericEligibilities < ActiveRecord::Migration[7.0]
  def change
    create_table :generic_eligibilities, id: :uuid do |t|
      t.uuid :school_id
      t.string :policy_name
      t.integer :award_amount

      t.timestamps
    end
  end
end
