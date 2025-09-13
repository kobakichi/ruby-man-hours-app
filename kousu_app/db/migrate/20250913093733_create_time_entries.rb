class CreateTimeEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :time_entries do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true
      t.references :task, null: false, foreign_key: true
      t.date :work_date
      t.integer :minutes
      t.text :note
      t.boolean :billable
      t.datetime :approved_at
      t.integer :approved_by_id

      t.timestamps
    end
  end
end
