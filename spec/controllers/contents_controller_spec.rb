require 'rails_helper'

describe ContentsController, type: :controller do
  let(:admin) { create(:user) }
  let(:author0) { create(:user) }
  let(:author1) { create(:user) }
  let(:reviewer0) { create(:user) }
  let(:reviewer1) { create(:user) }

  let!(:protocol) { create(:protocol) }
  let!(:content) { protocol.contents.find_by(no: 0) }
  let!(:participation1) { create(:admin, protocol: protocol, user: admin) }
  let!(:participation2) { create(:author, protocol: protocol, user: author0, sections: [0, 1, 2]) }
  let!(:participation3) { create(:author, protocol: protocol, user: author1, sections: [3, 4, 5]) }
  let!(:participation4) { create(:reviewer, protocol: protocol, user: reviewer0, sections: [0, 1, 2]) }
  let!(:participation5) { create(:reviewer, protocol: protocol, user: reviewer1, sections: [3, 4, 5]) }

  let!(:status_new) do
    protocol.contents.find_by(no: 1, seq: 1)
  end
  let!(:in_progress) do
    content = protocol.contents.find_by(no: 2, seq: 1)
    content.update_attributes(status: 'in_progress')
    content
  end
  let!(:under_review) do
    content = protocol.contents.find_by(no: 2, seq: 2)
    content.update_attributes(status: 'under_review')
    content
  end
  let!(:final) do
    content = protocol.contents.find_by(no: 2, seq: 3)
    content.update_attributes(status: 'final')
    content
  end

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
      expect(response).to be_success
    end
  end

  shared_examples_for 'can see compare' do
    it do
      get :history, xhr: true, params: { protocol_id: protocol, id: content }
      expect(response).to be_success
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

  shared_examples_for 'can see content' do
    it do
      get :show, params: { protocol_id: protocol, id: content }
      expect(response).to render_template :show
    end
  end

  shared_examples_for 'can change status from' do |before, after|
    it "#{before} to #{after}" do
      current_content = eval(before)
      patch :change_status, params: { protocol_id: protocol, id: current_content, content: { status: after } }
      current_content.reload
      expect(current_content.status).to eq after
    end
  end

  shared_examples_for 'can not change status from' do |before, after|
    it "#{before} to #{after}" do
      current_content = eval(after)
      patch :change_status, params: { protocol_id: protocol, id: current_content, content: { status: after } }
      expect(response).to redirect_to root_path
    end
  end

  context 'admin' do
    let!(:current_user) { admin }
    it_should_behave_like 'can update content'
    it_should_behave_like 'can see history'
    it_should_behave_like 'can see compare'
    it_should_behave_like 'can see content'
    it_should_behave_like 'can not change status from', 'status_new', 'in_progress'
    it_should_behave_like 'can change status from', 'status_new', 'under_review'
    it_should_behave_like 'can not change status from', 'status_new', 'final'
    it_should_behave_like 'can not change status from', 'in_progress', 'status_new'
    it_should_behave_like 'can change status from', 'in_progress', 'under_review'
    it_should_behave_like 'can not change status from', 'in_progress', 'final'
    it_should_behave_like 'can not change status from', 'under_review', 'status_new'
    it_should_behave_like 'can change status from', 'under_review', 'in_progress'
    it_should_behave_like 'can change status from', 'under_review', 'final'
    it_should_behave_like 'can not change status from', 'final', 'status_new'
    it_should_behave_like 'can change status from', 'final', 'in_progress'
    it_should_behave_like 'can not change status from', 'final', 'under_review'
  end

  context 'author' do
    let!(:current_user) { author0 }
    it_should_behave_like 'can update content'
    it_should_behave_like 'can see history'
    it_should_behave_like 'can see compare'
    it_should_behave_like 'can see content'
    it_should_behave_like 'can not change status from', 'status_new', 'in_progress'
    it_should_behave_like 'can change status from', 'status_new', 'under_review'
    it_should_behave_like 'can not change status from', 'status_new', 'final'
    it_should_behave_like 'can not change status from', 'in_progress', 'status_new'
    it_should_behave_like 'can change status from', 'in_progress', 'under_review'
    it_should_behave_like 'can not change status from', 'in_progress', 'final'
    it_should_behave_like 'can not change status from', 'under_review', 'status_new'
    it_should_behave_like 'can change status from', 'under_review', 'in_progress'
    it_should_behave_like 'can not change status from', 'under_review', 'final'
    it_should_behave_like 'can not change status from', 'final', 'status_new'
    it_should_behave_like 'can change status from', 'final', 'in_progress'
    it_should_behave_like 'can not change status from', 'final', 'under_review'
  end

  context 'reviewer' do
    let!(:current_user) { reviewer0 }
    it_should_behave_like 'can not update content'
    it_should_behave_like 'can see history'
    it_should_behave_like 'can see compare'
    it_should_behave_like 'can see content'
    it_should_behave_like 'can not change status from', 'status_new', 'in_progress'
    it_should_behave_like 'can not change status from', 'status_new', 'under_review'
    it_should_behave_like 'can not change status from', 'status_new', 'final'
    it_should_behave_like 'can not change status from', 'in_progress', 'status_new'
    it_should_behave_like 'can not change status from', 'in_progress', 'under_review'
    it_should_behave_like 'can not change status from', 'in_progress', 'final'
    it_should_behave_like 'can not change status from', 'under_review', 'status_new'
    it_should_behave_like 'can change status from', 'under_review', 'in_progress'
    it_should_behave_like 'can change status from', 'under_review', 'final'
    it_should_behave_like 'can not change status from', 'final', 'status_new'
    it_should_behave_like 'can change status from', 'final', 'in_progress'
    it_should_behave_like 'can not change status from', 'final', 'under_review'
  end

  %w[author reviewer].each do |role|
    context "other section #{role}" do
      let!(:current_user) { eval("#{role}1") }
      it_should_behave_like 'can not update content'
      it_should_behave_like 'can see history'
      it_should_behave_like 'can see compare'
      it_should_behave_like 'can see content'
      it_should_behave_like 'can not change status from', 'status_new', 'in_progress'
      it_should_behave_like 'can not change status from', 'status_new', 'under_review'
      it_should_behave_like 'can not change status from', 'status_new', 'final'
      it_should_behave_like 'can not change status from', 'in_progress', 'status_new'
      it_should_behave_like 'can not change status from', 'in_progress', 'under_review'
      it_should_behave_like 'can not change status from', 'in_progress', 'final'
      it_should_behave_like 'can not change status from', 'under_review', 'status_new'
      it_should_behave_like 'can not change status from', 'under_review', 'in_progress'
      it_should_behave_like 'can not change status from', 'under_review', 'final'
      it_should_behave_like 'can not change status from', 'final', 'status_new'
      it_should_behave_like 'can not change status from', 'final', 'in_progress'
      it_should_behave_like 'can not change status from', 'final', 'under_review'
    end
  end
end
