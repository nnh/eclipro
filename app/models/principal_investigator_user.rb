class PrincipalInvestigatorUser < ApplicationRecord
  belongs_to :protocol
  belongs_to :user
end
