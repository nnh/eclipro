require 'rails_helper'

describe ContentsController, type: :controller do
  let(:pi) { create(:user) }
  let(:co) { create(:user) }
  let!(:protocol) { create(:protocol, principal_investigator: pi, co_authors: [co]) }

  let(:author0) { create(:user) }
  let!(:author_user0) { create(:author_user, protocol: protocol, user: author0, sections: '0')}
  let(:author1) { create(:user) }
  let!(:author_user1) { create(:author_user, protocol: protocol, user: author1, sections: '1')}
  let(:reviewer0) { create(:user) }
  let!(:reviewer_user0) { create(:reviewer_user, protocol: protocol, user: reviewer0, sections: '0')}
  let(:reviewer1) { create(:user) }
  let!(:reviewer_user1) { create(:reviewer_user, protocol: protocol, user: reviewer1, sections: '1')}

  before(:each) { sign_in(pi) }

  describe '#update' do
    xit 'wip' do
    end
  end
end
