# This migration comes from irp (originally 20231116165122)
class CreateIrpReportTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :irp_report_templates do |t|
      t.string :report_class
      t.string :filename
      t.binary :file
      t.jsonb :config

      t.timestamps
    end

    add_index :irp_report_templates, :report_class, unique: true
  end
end
