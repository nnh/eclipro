require 'rails_helper'

describe ContentsController, type: :controller do
  let(:pi) { create(:user) }
  let(:co) { create(:user) }
  let(:author0) { create(:user) }
  let(:author1) { create(:user) }
  let(:reviewer0) { create(:user) }
  let(:reviewer1) { create(:user) }

  let!(:protocol) { create(:protocol) }
  let!(:content) { protocol.contents.find_by(no: '0') }
  let!(:participation0) { create(:principal_investigator, protocol: protocol, user: pi) }
  let!(:participation1) { create(:co_author, protocol: protocol, user: co) }
  let!(:participation2) { create(:author, protocol: protocol, user: author0, sections: [0]) }
  let!(:participation3) { create(:author, protocol: protocol, user: author1, sections: [1]) }
  let!(:participation4) { create(:reviewer, protocol: protocol, user: reviewer0, sections: [0]) }
  let!(:participation5) { create(:reviewer, protocol: protocol, user: reviewer1, sections: [1]) }

  before(:each) { sign_in(current_user) }

  shared_examples_for 'can update content' do
    it do
      patch :update, params: { protocol_id: protocol, id: content, content: { body: 'update content' } }
      content.reload
      expect(content.body).to eq 'update content'
    end
  end

  shared_examples_for 'can not update content' do
    it do
      patch :update, params: { protocol_id: protocol, id: content, content: { body: 'update content' } }
      expect(response).to redirect_to root_path
    end
  end

  shared_examples_for 'can see history' do
    it do
      get :history, xhr: true, params: { protocol_id: protocol, id: content }
      response.should be_success
    end
  end

  shared_examples_for 'can see compare' do
    it do
      get :history, xhr: true, params: { protocol_id: protocol, id: content }
      response.should be_success
    end
  end

  shared_examples_for 'can revert content' do
    it do
      origin_text = content.body
      patch :update, params: { protocol_id: protocol, id: content, content: { body: 'update content' } }
      patch :revert, params: { protocol_id: protocol, id: content, content: { index: 0 } }
      content.reload
      expect(content.body).to eq origin_text
    end
  end

  shared_examples_for 'can not revert content' do
    it do
      patch :update, params: { protocol_id: protocol, id: content, content: { body: 'update content' } }
      patch :revert, params: { protocol_id: protocol, id: content, content: { index: 0 } }
      expect(response).to redirect_to root_path
    end
  end

  context 'principal_investigator' do
    let!(:current_user) { pi }
    it_should_behave_like 'can update content'
    it_should_behave_like 'can see history'
    it_should_behave_like 'can see compare'
  end

  context 'co_author' do
    let!(:current_user) { co }
    it_should_behave_like 'can update content'
    it_should_behave_like 'can see history'
    it_should_behave_like 'can see compare'
  end

  context 'author' do
    let!(:current_user) { author0 }
    it_should_behave_like 'can update content'
    it_should_behave_like 'can see history'
    it_should_behave_like 'can see compare'
  end

  context 'other section author' do
    let!(:current_user) { author1 }
    it_should_behave_like 'can not update content'
    it_should_behave_like 'can see history'
    it_should_behave_like 'can see compare'
  end

  context 'reviewer' do
    let!(:current_user) { reviewer0 }
    it_should_behave_like 'can not update content'
    it_should_behave_like 'can see history'
    it_should_behave_like 'can see compare'
  end

  context 'other section reviewer' do
    let!(:current_user) { reviewer0 }
    it_should_behave_like 'can not update content'
    it_should_behave_like 'can see history'
    it_should_behave_like 'can see compare'
  end

  describe '#change_status' do
    xit 'wip' do
    end
  end

  describe '#show' do
    xit 'wip' do
    end
  end
end
