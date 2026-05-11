class AddDoneToAssignments < ActiveRecord::Migration[8.1]
  def change
    add_column :assignments, :done, :boolean
  end
end
