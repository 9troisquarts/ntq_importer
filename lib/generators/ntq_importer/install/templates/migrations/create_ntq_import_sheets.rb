class CreateNtqImportSheets < ActiveRecord::Migration
  def change
    create_table :ntq_import_sheets do |t|
      t.string :name
      t.belongs_to :ntq_import
      t.timestamps
    end
  end
end