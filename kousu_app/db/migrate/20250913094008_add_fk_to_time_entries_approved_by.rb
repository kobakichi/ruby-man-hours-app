class AddFkToTimeEntriesApprovedBy < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :time_entries, :users, column: :approved_by_id
  end
end
