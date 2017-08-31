class ChangeColumnToContent < ActiveRecord::Migration[5.1]
  def change
    change_column :contents, :status, :integer, null: false, default: 0
  end
end
