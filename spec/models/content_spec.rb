require 'rails_helper'

describe Content do
  let(:protocol) { create(:protocol) }
  let(:reviewer) { create(:user) }
  let!(:reviewer_participation) { create(:reviewer, protocol: protocol, user: reviewer, sections: [0]) }

  context 'has_reviewer?' do
    it { expect(protocol.contents.root.has_reviewer?).to eq(true) }
    it { expect(protocol.contents.find_by(no: 1, seq: 0).has_reviewer?).to eq(false) }
  end
end
