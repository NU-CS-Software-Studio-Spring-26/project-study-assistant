class AddJoinPasswordToStudyGroups < ActiveRecord::Migration[8.1]
  def change
    add_column :study_groups, :join_password, :string
  end
end