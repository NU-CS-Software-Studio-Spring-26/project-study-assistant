class AddIcalMetadataToAssignments < ActiveRecord::Migration[8.1]
  def change
    add_column :assignments, :source, :string, null: false, default: "manual"
    add_column :assignments, :due_time_confirmed, :boolean, null: false, default: true
    add_index :assignments, [ :user_id, :canvas_id ], unique: true, where: "canvas_id IS NOT NULL"
  end
end
