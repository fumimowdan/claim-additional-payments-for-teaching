class AddColFormSchoolId < ActiveRecord::Migration[7.0]
  def change
    add_column :irp_forms, :school_id, :uuid
  end
end
