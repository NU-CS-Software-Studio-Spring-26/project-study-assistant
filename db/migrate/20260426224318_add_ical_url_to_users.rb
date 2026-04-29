class AddIcalUrlToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :ical_url, :string
  end
end
