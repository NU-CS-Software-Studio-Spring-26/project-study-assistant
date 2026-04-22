class CreateAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :assignments do |t|
      t.string :title
      t.string :course_name
      t.datetime :due_date
      t.integer :estimated_hours
      t.boolean :synced_to_calendar

      t.timestamps
    end
  end
end
