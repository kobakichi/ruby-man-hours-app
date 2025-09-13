class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name
      t.string :client_name
      t.boolean :billable
      t.integer :budget_hours
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
