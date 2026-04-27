class RemoveCanvasTokenAndCalendarPreferenceFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :canvas_token, :string
    remove_column :users, :calendar_preference, :string
  end
end
