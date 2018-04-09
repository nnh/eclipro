require 'rails_helper'

describe ReferenceDocxesController, type: :controller do
  let(:admin) { create(:user) }
  let(:user) { create(:user) }
  let!(:new_protocol) { create(:protocol) }
  let!(:exist_protocol) { create(:protocol) }
  let!(:reference_docx) { create(:reference_docx, protocol: exist_protocol) }

  let!(:participation0) { create(:admin, protocol: new_protocol, user: admin) }
  let!(:participation1) { create(:admin, protocol: exist_protocol, user: admin) }
  let!(:participation2) { create(:author, protocol: new_protocol, user: user) }
  let!(:participation3) { create(:author, protocol: exist_protocol, user: user) }

  let!(:content_type) { 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' }

  before(:each) { sign_in(current_user) }

  context 'admin user' do
    let(:current_user) { admin }

    describe 'POST #create' do
      it 'creates @reference_docx' do
        expect do
          post :create, params: { protocol_id: new_protocol,
                                  reference_docx: { file: fixture_file_upload('reference.docx', content_type) } }
        end.to change(ReferenceDocx, :count).by(1)
      end
    end

    describe 'GET #show' do
      it 'send_data @reference_docx' do
        get :show, params: { id: reference_docx, protocol_id: exist_protocol }
        expect(assigns(:reference_docx)).to eq reference_docx
        expect(response.header['Content-Disposition']).to include(reference_docx.file_file_name)
      end
    end

    describe 'PATCH #update' do
      it 'updates @reference_docx' do
        patch :update, params: { protocol_id: exist_protocol, id: reference_docx,
                                 reference_docx: { file: fixture_file_upload('reference2.docx', content_type) } }
        exist_protocol.reload
        expect(exist_protocol.reference_docx.file_file_name).to eq('reference2.docx')
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys @reference_docx' do
        expect do
          delete :destroy, params: { protocol_id: exist_protocol, id: reference_docx }
        end.to change(ReferenceDocx, :count).by(-1)
      end
    end
  end

  context 'not admin user' do
    let(:current_user) { user }

    describe 'POST #create' do
      it 'redirect_to root_path' do
        post :create, params: { protocol_id: new_protocol,
                                reference_docx: { file: fixture_file_upload('reference.docx', content_type) } }
        expect(response).to redirect_to root_path
      end
    end

    describe 'GET #show' do
      it 'send_data @reference_docx' do
        get :show, params: { protocol_id: exist_protocol, id: reference_docx }
        expect(assigns(:reference_docx)).to eq reference_docx
        expect(response.header['Content-Disposition']).to include(reference_docx.file_file_name)
      end
    end

    describe 'PATCH #update' do
      it 'redirect_to root_path' do
        patch :update, params: { protocol_id: exist_protocol, id: reference_docx,
                                 reference_docx: { file: fixture_file_upload('reference2.docx', content_type) } }
        expect(response).to redirect_to root_path
      end
    end

    describe 'DELETE #destroy' do
      it 'redirect_to root_path' do
        delete :destroy, params: { protocol_id: exist_protocol, id: reference_docx }
        expect(response).to redirect_to root_path
      end
    end
  end
end
