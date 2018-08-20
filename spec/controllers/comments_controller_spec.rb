require 'rails_helper'

describe CommentsController, type: :controller do
  let(:user) { create(:user) }
  let!(:protocol) { create(:protocol) }
  let!(:participation) { create(:admin, protocol: protocol, user: user)}
  let!(:comment) { create(:comment, content: protocol.contents.root)}

  before(:each) { sign_in(user) }

  describe '#index' do
    it 'user can see comments' do
      get :index, xhr: true, params: { protocol_id: protocol.id,
                                       content_id: protocol.contents.root.id }
      expect(assigns(:comments)).to match_array([comment])
    end
  end

  describe '#create' do
    it 'user can create comment' do
      content_id = protocol.contents.root.id
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
      content_id = protocol.contents.root.id
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
end
