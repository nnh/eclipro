require 'rails_helper'

describe ImagesController, type: :controller do
  let(:admin) { create(:user) }
  let(:user) { create(:user) }
  let(:protocol) { create(:protocol) }
  let(:content) { protocol.contents.find_by(no: 1, seq: 1) }
  let(:image) { content.images.create(file: fixture_file_upload('test.png', 'image/png')) }
  let!(:participation) { create(:admin, protocol: protocol, user: admin) }

  before(:each) { sign_in(current_user) }

  describe '#create' do
    context 'updatable user' do
      let!(:current_user) { admin }
      it 'can create image' do
        expect do
          post :create, xhr: true, params: { protocol_id: protocol, content_id: content,
                                             file: fixture_file_upload('test.png', 'image/png') }
        end.to change(Image, :count).by(1)
      end
    end
    context 'not updatable user' do
      let!(:current_user) { user }
      it 'can not create image' do
        post :create, xhr: true, params: { protocol_id: protocol, content_id: content,
                                           file: fixture_file_upload('test.png', 'image/png') }
        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#show' do
    context 'participating user' do
      let!(:current_user) { admin }
      it 'can see image' do
        expect(controller).to receive(:open).with(image.file.expiring_url(10.minutes.to_i), 'rb')
        get :show, xhr: true, params: { protocol_id: protocol, content_id: content, id: image }
      end
    end
    context 'not participating user' do
      let!(:current_user) { user }
      it 'can not see image' do
        get :show, xhr: true, params: { protocol_id: protocol, content_id: content, id: image }
        expect(response).to redirect_to root_path
      end
    end
  end
end
