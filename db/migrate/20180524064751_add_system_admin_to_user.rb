class AddSystemAdminToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :system_admin, :boolean, default: false
  end
end
