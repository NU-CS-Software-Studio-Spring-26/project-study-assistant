class AddUserIdAndCanvasIdToAssignments < ActiveRecord::Migration[8.1]
  def change
    add_column :assignments, :user_id, :integer
    add_column :assignments, :canvas_id, :string
  end
end
