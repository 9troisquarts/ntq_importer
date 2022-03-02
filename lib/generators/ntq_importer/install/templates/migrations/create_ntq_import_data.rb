class CreateNtqImportData < ActiveRecord::Migration
  def change
    create_table :ntq_import_data do |t|
      t.text :content
      t.integer :line_index
      t.integer :column_index
      t.belongs_to :ntq_import
      t.belongs_to :ntq_import_sheet
      t.belongs_to :ntq_import_header
      t.timestamps
    end
  end
end