class AddDetailsToStudyGroups < ActiveRecord::Migration[8.1]
  def change
    add_column :study_groups, :description, :text
  end
end
