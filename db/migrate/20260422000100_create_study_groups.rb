class CreateStudyGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :study_groups do |t|
      t.string :name, null: false
      t.datetime :study_time, null: false
      t.string :location_mode, null: false
      t.string :communication_style, null: false
      t.string :tags, array: true, default: [], null: false
      t.references :creator, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end