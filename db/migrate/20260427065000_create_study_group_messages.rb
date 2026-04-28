class CreateStudyGroupMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :study_group_messages do |t|
      t.references :study_group, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false

      t.timestamps
    end

    add_index :study_group_messages, [ :study_group_id, :created_at ]
  end
end
