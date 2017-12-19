require 'rails_helper'

describe CommentsController, type: :controller do
  let(:user) { create(:user) }
  let!(:protocol) { create(:protocol) }
  let!(:participation) { create(:principal_investigator, protocol: protocol, user: user)}
  let!(:comment) { create(:comment, content: protocol.contents.find_by(no: '0'))}

  before(:each) { sign_in(user) }

  describe '#index' do
    it 'user can see comments' do
      get :index, xhr: true, params: { protocol_id: protocol.id,
                                       content_id: protocol.contents.find_by(no: '0').id }
      expect(response).to render_template :index
      expect(assigns(:comments)).to match_array([comment])
    end
  end

  describe '#create' do
    it 'user can create comment' do
      content_id = protocol.contents.find_by(no: '0').id
      expect {
        post :create, xhr: true, params: { protocol_id: protocol.id,
                                           content_id: content_id,
                                           comment: attributes_for(:comment,
                                                                   content_id: content_id,
                                                                   user_id: user.id,
                                                                   body: 'comment create test') }
      }.to change(Comment, :count).by(1)
    end
  end

  describe '#resolve' do
    it 'user can resolve comment' do
      content_id = protocol.contents.find_by(no: '0').id
      put :resolve, xhr: true, params: { protocol_id: protocol.id,
                                         content_id: content_id,
                                         id: comment.id,
                                         comment: attributes_for(:comment,
                                                                 content_id: content_id,
                                                                 resolve: true) }
      comment.reload
      expect(comment.resolve).to eq true
    end
  end

  describe '#comment' do
    it 'user can comment (create comment form)' do
      get :comment, xhr: true, params: { protocol_id: protocol.id,
                                         content_id: protocol.contents.find_by(no: '0').id }
      expect(response).to render_template :comment
    end
  end

  describe '#reply' do
    it 'user can reply' do
      content_id = protocol.contents.find_by(no: '0').id
      get :reply, xhr: true, params: { protocol_id: protocol.id,
                                       content_id: content_id,
                                       comment: attributes_for(:comment, parent_id: comment.id) }
      expect(response).to render_template :reply

      expect {
        post :create, xhr: true, params: { protocol_id: protocol.id,
                                           content_id: content_id,
                                           comment: attributes_for(:comment,
                                                                   content_id: content_id,
                                                                   user_id: user.id,
                                                                   parent_id: comment.id,
                                                                   body: 'comment reply test') }
      }.to change(Comment, :count).by(1)
      expect(Comment.last.parent_id).to eq(comment.id)
    end
  end
end
