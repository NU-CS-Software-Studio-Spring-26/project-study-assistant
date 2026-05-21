class AddBannerUrlToStudyGroups < ActiveRecord::Migration[8.1]
  def change
    add_column :study_groups, :banner_url, :string
  end
end
