require 'rails_helper'

describe ContentsController, type: :controller do
  let(:pi) { create(:user) }
  let(:co) { create(:user) }
  let(:author0) { create(:user) }
  let(:author1) { create(:user) }
  let(:reviewer0) { create(:user) }
  let(:reviewer1) { create(:user) }

  let!(:protocol) { create(:protocol) }
  let!(:participation0) { create(:principal_investigator, protocol: protocol, user: pi) }
  let!(:participation1) { create(:co_author, protocol: protocol, user: co) }
  let!(:participation2) { create(:author, protocol: protocol, user: author0, sections: [0]) }
  let!(:participation3) { create(:author, protocol: protocol, user: author1, sections: [1]) }
  let!(:participation4) { create(:reviewer, protocol: protocol, user: reviewer0, sections: [0]) }
  let!(:participation5) { create(:reviewer, protocol: protocol, user: reviewer1, sections: [1]) }

  before(:each) { sign_in(pi) }

  describe '#update' do
    xit 'wip' do
    end
  end
end
