require 'rails_helper'

describe SectionsController, type: :controller do
  let(:admin) { create(:user) }
  let(:user) { create(:user) }

  before(:each) { sign_in(current_user) }

  # TODO: ability

  context 'editable user' do
    let(:current_user) { admin }
    let(:section) { create(:section) }

    describe 'GET #index' do
      it 'show @sections' do
        get :index
        expect(response).to render_template :index
        expect(assigns(:sections).count).to eq(Section.all.count)
      end
    end

    describe 'GET #show' do
      it 'show @section' do
        get :show, params: { id: section }
        expect(response).to render_template :show
        expect(assigns(:section)).to eq section
      end
    end

    describe 'GET #edit' do
      it 'renders edit template' do
        get :edit, params: { id: section }
        expect(response).to render_template :edit
      end
    end

    describe 'PATCH #update' do
      it 'updates @section' do
        patch :update, params: { id: section, section: { title: 'edited title' } }
        section.reload
        expect(section.title).to eq('edited title')
      end
    end
  end

  context 'not editable user' do
    let(:current_user) { user }
    let!(:section) { create(:section) }

    describe 'GET #index' do
      it 'show @sections' do
        get :index
        expect(assigns(:sections).count).to eq(Section.all.count)
      end
    end

    describe 'GET #show' do
      it 'show @section' do
        get :show, params: { id: section }
        expect(assigns(:section)).to eq section
      end
    end

    # describe 'GET #edit' do
    #   it 'redirect_to root_path (not renders edit template)' do
    #     get :edit, params: { id: section }
    #     expect(response).to redirect_to root_path
    #   end
    # end

    # describe 'PATCH #update' do
      # it 'redirect_to root_path (not updates @section)' do
        # patch :update, params: { id: section, section: { title: 'edited title' } }
        # expect(response).to redirect_to root_path
      # end
    # end
  end
end
