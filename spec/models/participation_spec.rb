require 'rails_helper'

describe Participation do
  let(:protocol) { create(:protocol) }
  let(:user) { create(:user) }
  let(:new_user) { create(:user) }
  let!(:admin_participation) { create(:admin, protocol: protocol, user: user) }

  describe 'validation' do
    context 'user has only one role' do
      it { expect(build(:author, protocol: protocol, user: user)).not_to be_valid }
      it { expect(build(:author, protocol: create(:protocol), user: user)).to be_valid }
    end

    context 'has sections at least one' do
      it { expect(build(:author, protocol: protocol, user: new_user, sections: [])).not_to be_valid }
      it { expect(build(:author, protocol: protocol, user: new_user, sections: [1])).to be_valid }
    end
  end
end
