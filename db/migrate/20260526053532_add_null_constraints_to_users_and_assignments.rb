class AddNullConstraintsToUsersAndAssignments < ActiveRecord::Migration[8.1]
  class MigrationUser < ApplicationRecord
    self.table_name = "users"
  end

  class MigrationAssignment < ApplicationRecord
    self.table_name = "assignments"
  end

  def up
    change_column_null :users, :email, false
    change_column_null :users, :name, false
    change_column_null :assignments, :title, false

    backfill_assignment_user_ids
    change_column_null :assignments, :user_id, false
  end

  def down
    change_column_null :assignments, :user_id, true
    change_column_null :assignments, :title, true
    change_column_null :users, :name, true
    change_column_null :users, :email, true
  end

  private

  def backfill_assignment_user_ids
    return unless MigrationAssignment.where(user_id: nil).exists?

    owner_id = MigrationUser.order(:id).pick(:id)
    raise ActiveRecord::IrreversibleMigration, "Cannot backfill assignments without an existing user" if owner_id.blank?

    MigrationAssignment.where(user_id: nil).update_all(user_id: owner_id)
  end
end
