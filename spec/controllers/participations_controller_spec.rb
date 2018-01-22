require 'rails_helper'

describe ParticipationsController, type: :controller do
  let(:admin_user) { create(:user) }
  let(:general_user) { create(:user) }
  let(:new_user) { create(:user) }
  let(:protocol) { create(:protocol) }
  let!(:pi_participation) { create(:principal_investigator, protocol: protocol, user: admin_user) }
  let!(:author_participation) { create(:author, protocol: protocol, user: general_user) }

  before(:each) { sign_in(current_user) }

  describe '#new' do
    context 'admin user' do
      let!(:current_user) { admin_user }
      it 'can move to new participation page' do
        get :new, params: { protocol_id: protocol.id }
        expect(response).to render_template :new
      end
    end
    context 'general user' do
      let!(:current_user) { general_user }
      it 'not admin user can not move to new participation page' do
        get :new, params: { protocol_id: protocol.id }
        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#create' do
    context 'admin user' do
      let!(:current_user) { admin_user }
      it 'can create participation' do
        expect do
          post :create, params: { protocol_id: protocol.id,
                                  participation: attributes_for(:participation, protocol_id: protocol.id, user_id: new_user.id,
                                                                                role: 'author', sections: [0]) }
        end.to change(Participation, :count).by(1)
      end
    end
    context 'general user' do
      let!(:current_user) { general_user }
      it 'can not create participation' do
        post :create, params: { protocol_id: protocol.id,
                                participation: attributes_for(:participation, protocol_id: protocol.id, user_id: new_user.id,
                                                                              role: 'author', sections: [0]) }
        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#destroy' do
    context 'admin user' do
      let!(:current_user) { admin_user }
      it 'can destroy participation' do
        expect do
          delete :destroy, params: { id: author_participation.id, protocol_id: protocol.id }
        end.to change(Participation, :count).by(-1)
      end
    end
    context 'general user' do
      let!(:current_user) { general_user }
      it 'can not destroy participation' do
        delete :destroy, params: { id: author_participation.id, protocol_id: protocol.id }
        expect(response).to redirect_to root_path
      end
    end
  end
end
