require 'rails_helper'

describe Participation do
  let(:protocol) { create(:protocol) }
  let(:new_user) { create(:user) }
  let!(:pi_participation) { create(:principal_investigator, protocol: protocol, user: create(:user)) }

  describe 'validation' do
    context 'principal_investigator role is unique' do
      it { expect(build(:principal_investigator, protocol: protocol, user: new_user)).not_to be_valid }
      it { expect(build(:principal_investigator, protocol: create(:protocol), user: new_user)).to be_valid }
    end

    context 'has sections at least one' do
      it { expect(build(:author, protocol: protocol, user: new_user, sections: [])).not_to be_valid }
      it { expect(build(:author, protocol: protocol, user: new_user, sections: [1])).to be_valid }
    end
  end
end
