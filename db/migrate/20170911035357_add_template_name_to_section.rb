class AddTemplateNameToSection < ActiveRecord::Migration[5.1]
  def change
    add_column :sections, :template_name, :string, null: false, default: 'General'
    add_column :protocols, :template_name, :string, null: false, default: 'General'
  end
end
