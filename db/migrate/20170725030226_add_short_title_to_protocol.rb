class AddShortTitleToProtocol < ActiveRecord::Migration[5.1]
  def change
    add_column :protocols, :short_title, :string
    add_column :protocols, :protocol_number, :string
    add_column :protocols, :nct_number, :string
    add_column :protocols, :sponsors, :text
    add_column :protocols, :sponsor_other, :string
    add_column :protocols, :entity_funding_name, :string
    add_column :protocols, :study_agent, :text
    add_column :protocols, :has_ide, :integer
    add_column :protocols, :has_ind, :integer
    add_column :protocols, :compliance, :integer, default: 0
  end
end
