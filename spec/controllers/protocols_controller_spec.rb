require 'rails_helper'

describe ProtocolsController, type: :controller do
  let(:admin_user) { create(:user) }
  let(:general_user) { create(:user) }
  let(:protocol0) { create(:protocol, title: 'test') }
  let(:protocol1) { create(:protocol, title: 'abcde', status: 'finalized') }
  let(:protocol2) { create(:protocol) }
  let!(:pi_participation0) { create(:principal_investigator, protocol: protocol0, user: admin_user) }
  let!(:pi_participation1) { create(:principal_investigator, protocol: protocol1, user: admin_user) }
  let!(:author_participation0) { create(:author, protocol: protocol0, user: general_user) }
  let!(:author_participation1) { create(:author, protocol: protocol1, user: general_user) }

  before(:each) { sign_in(current_user) }

  describe '#index' do
    context 'all user' do
      let(:current_user) { general_user }
      it 'can see participating protocols' do
        get :index
        expect(response).to render_template :index
        expect(assigns(:protocols)).to match_array([protocol0, protocol1])
      end
    end
  end

  describe '#index with filter' do
    context 'all user' do
      let(:current_user) { general_user }
      it 'can see participating protocols with filter' do
        get :index, params: { protocol_name_filter: 'test' }
        expect(response).to render_template :index
        expect(assigns(:protocols)).to match_array([protocol0])
      end
    end
  end

  describe '#show' do
    context 'all user' do
      let(:current_user) { general_user }
      it 'can move to show protocol page' do
        get :show, params: { id: protocol0 }
        expect(response).to render_template :show
      end
    end
  end

  describe '#new' do
    context 'all user' do
      let(:current_user) { general_user }
      it 'can move to new protocol page' do
        get :new
        expect(response).to render_template :new
      end
    end
  end

  describe '#edit' do
    context 'admin user' do
      let!(:current_user) { admin_user }
      it 'can move to edit protocol page' do
        get :edit, params: { id: protocol0 }
        expect(response).to render_template :edit
      end
    end
    context 'general user' do
      let!(:current_user) { general_user }
      it 'can not move to edit protocol page' do
        get :edit, params: { id: protocol0 }
        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#create' do
    context 'all user' do
      let(:current_user) { general_user }
      it 'can create new protocol' do
        expect do
          post :create, params: { protocol: { title: 'Test' } }
        end.to change(Protocol, :count).by(1)
      end
    end
  end

  describe '#update' do
    context 'admin user' do
      let!(:current_user) { admin_user }
      it 'can update protocol' do
        patch :update, params: { id: protocol0, protocol: { title: 'new protocol' } }
        protocol0.reload
        expect(protocol0.title).to eq('new protocol')
      end
    end
    context 'general user' do
      let!(:current_user) { general_user }
      it 'can not update protocol' do
        patch :update, params: { id: protocol0, protocol: { title: 'new protocol' } }
        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#destroy' do
    context 'admin user' do
      let!(:current_user) { admin_user }
      it 'can destroy protocol' do
        expect do
          delete :destroy, params: { id: protocol0 }
        end.to change(Protocol, :count).by(-1)
      end
    end
    context 'general user' do
      let!(:current_user) { general_user }
      it 'can not destroy protocol' do
        delete :destroy, params: { id: protocol0 }
        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#clone' do
    context 'all user' do
      let(:current_user) { general_user }
      it 'can move to clone protocol page' do
        get :clone, params: { id: protocol0 }
        expect(response).to render_template :clone
      end
    end
  end

  describe '#export pdf' do
    context 'all user' do
      let(:current_user) { general_user }
      it 'can export protocol (protocol status is finalized)' do
        get :export, format: :pdf, params: { id: protocol1 }
        expect(response.header['Content-Type']).to include('application/pdf')
      end
    end
  end

  describe '#export docx' do
    context 'all user' do
      let(:current_user) { general_user }
      it 'can export protocol (protocol status is finalized)' do
        get :export, format: :docx, params: { id: protocol1 }
        expect(response.header['Content-Type']).to include('application/vnd.openxmlformats-officedocument.wordprocessingml.document')
      end
    end
  end

  describe '#finalize' do
    context 'admin user' do
      let!(:current_user) { admin_user }
      it 'can change protocol status to "finalized"' do
        get :finalize, params: { id: protocol0 }
        protocol0.reload
        expect(protocol0.status).to eq 'finalized'
        expect(protocol0.contents[0].status).to eq 'final'
      end
    end
    context 'general user' do
      let!(:current_user) { general_user }
      it 'can not change protocol status' do
        get :finalize, params: { id: protocol0 }
        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#reinstate' do
    context 'admin user' do
      let!(:current_user) { admin_user }
      it 'can change protocol status to from "finalized" to "in_progress"' do
        get :reinstate, params: { id: protocol1 }
        protocol1.reload
        expect(protocol1.status).to eq 'in_progress'
        expect(protocol1.contents[0].status).to eq 'in_progress'
      end
    end
    context 'general user' do
      let!(:current_user) { general_user }
      it 'can not change protocol status' do
        get :reinstate, params: { id: protocol1 }
        expect(response).to redirect_to root_path
      end
    end
  end
end
