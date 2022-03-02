class CreateNtqImportHeaders < ActiveRecord::Migration
  def change
    create_table :ntq_import_headers do |t|
      t.string :name
      t.integer :line_index
      t.integer :column_index
      t.belongs_to :ntq_import
      t.belongs_to :ntq_import_sheet
      t.timestamps
    end
  end
end