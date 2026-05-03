class AddStartAndEndTimeToStudyGroups < ActiveRecord::Migration[8.1]
  class MigrationStudyGroup < ApplicationRecord
    self.table_name = "study_groups"
  end

  def up
    add_column :study_groups, :start_time, :datetime
    add_column :study_groups, :end_time, :datetime

    MigrationStudyGroup.reset_column_information
    MigrationStudyGroup.find_each do |study_group|
      next if study_group.study_time.blank?

      start_time = study_group.study_time
      end_time = start_time + 2.hours
      study_group.update_columns(start_time: start_time, end_time: end_time)
    end

    change_column_null :study_groups, :start_time, false
    change_column_null :study_groups, :end_time, false
  end

  def down
    remove_column :study_groups, :start_time
    remove_column :study_groups, :end_time
  end
end
