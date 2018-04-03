class AddPrincipalInvestigatorToProtocol < ActiveRecord::Migration[5.1]
  def up
    add_column :protocols, :principal_investigator, :string

    Protocol.all.each do |protocol|
      pi_participation = protocol.participations.where.not(role: Participation.roles.keys).first
      pi_participation.update_column(:role, 'admin')
      protocol.update_column(:principal_investigator, pi_participation.user.name)
    end
  end

  def down
    remove_column :protocols, :principal_investigator, :string
  end
end
