class AddTitleToContent < ActiveRecord::Migration[5.1]
  def change
    add_column :contents, :title, :string
    add_column :contents, :editable, :boolean
  end
end
