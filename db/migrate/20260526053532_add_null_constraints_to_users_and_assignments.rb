class AddNullConstraintsToUsersAndAssignments < ActiveRecord::Migration[8.1]
  def change
    change_column_null :users, :email, false
    change_column_null :users, :name, false
    change_column_null :assignments, :title, false
    change_column_null :assignments, :user_id, false
  end
end