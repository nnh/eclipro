class AddLockToContent < ActiveRecord::Migration[5.1]
  def change
    add_column :contents, :lock_version, :integer, null: false, default: 0
  end
end
