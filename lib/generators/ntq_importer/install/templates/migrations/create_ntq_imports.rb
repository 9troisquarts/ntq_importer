class CreateNtqImports < ActiveRecord::Migration
  def change
    create_table :ntq_imports do |t|
      t.string :type
      t.string :status
      t.string :filename
      t.string :sidekiq_jid
      t.timestamps
    end
  end
end