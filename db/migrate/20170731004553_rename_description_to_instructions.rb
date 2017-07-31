class RenameDescriptionToInstructions < ActiveRecord::Migration[5.1]
  def change
    rename_column :sections, :description, :instructions
    add_column :sections, :editable, :boolean
    remove_foreign_key :contents, :sections
    remove_reference :contents, :section, index: true
    add_column :contents, :no, :string
  end
end
