require 'rails_helper'

feature ReferenceDocx, js: true do
  let(:admin_user) { create(:user) }
  let(:general_user) { create(:user) }
  let(:protocol0) { create(:protocol, title: 'Test protocol') }
  let(:protocol1) { create(:protocol, title: 'Test protocol 2') }
  let!(:pi_participation0) { create(:principal_investigator, protocol: protocol0, user: admin_user) }
  let!(:pi_participation1) { create(:principal_investigator, protocol: protocol1, user: admin_user) }
  let!(:author_participation0) { create(:author, protocol: protocol0, user: general_user) }
  let!(:author_participation1) { create(:author, protocol: protocol1, user: general_user) }
  let!(:reference_docx) { create(:reference_docx, protocol: protocol1) }

  background(:each) do
    login_as(current_user, scope: :user)
  end


  feature 'admin user' do
    let!(:current_user) { admin_user }

    scenario 'create(upload) reference.docx' do
      visit protocol_path(protocol0)
      expect(page).to have_field('reference_docx[file]')

      attach_file 'reference_docx[file]', Rails.root.join('spec', 'fixtures', 'reference.docx')
      click_on 'Upload file'

      expect(page).to have_content('File check (Download)')
    end

    scenario 'show(download) reference.docx' do
      visit protocol_path(protocol1)
      expect(page).to have_content('File check (Download)')

      click_on 'File check (Download)'
      expect(page.response_headers['Content-Disposition']).to include('reference.docx')
    end

    scenario 'update reference.docx' do
      visit protocol_path(protocol1)

      attach_file 'reference_docx[file]', Rails.root.join('spec', 'fixtures', 'reference2.docx')
      click_on 'Upload file'

      click_on 'File check (Download)'
      expect(page.response_headers['Content-Disposition']).to include('reference2.docx')
    end

    scenario 'delete reference.docx' do
      visit protocol_path(protocol1)
      expect(page).to have_content('Delete')

      click_on 'Delete'
      expect(page).not_to have_content('Delete')
    end
  end

  feature 'general user' do
    let!(:current_user) { general_user }

    scenario 'can not create(upload) reference.docx' do
      visit protocol_path(protocol0)
      expect(page).not_to have_field('reference_docx[file]')
    end

    scenario 'can not show(download) reference.docx' do
      visit protocol_path(protocol1)
      expect(page).not_to have_content('File check (Download)')
    end

    scenario 'can not update reference.docx' do
      visit protocol_path(protocol1)
      expect(page).not_to have_field('reference_docx[file]')
    end

    scenario 'can not delete reference.docx' do
      visit protocol_path(protocol1)
      expect(page).not_to have_content('Delete')
    end
  end
end
