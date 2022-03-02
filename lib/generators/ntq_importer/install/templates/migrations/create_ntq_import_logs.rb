class CreateNtqImportLogs < ActiveRecord::Migration
  def change
    create_table :ntq_import_logs do |t|
      t.string :type
      t.text :message
      t.belongs_to :ntq_import
      t.belongs_to :ntq_import_header
      t.belongs_to :ntq_import_data
      t.timestamps
    end
  end
end