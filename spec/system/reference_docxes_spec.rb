require 'rails_helper'

feature ReferenceDocx, js: true, type: :system do
  let(:admin_user) { create(:user) }
  let(:general_user) { create(:user) }
  let(:protocol0) { create(:protocol, title: 'Test protocol') }
  let(:protocol1) { create(:protocol, title: 'Test protocol 2') }
  let!(:admin_participation0) { create(:admin, protocol: protocol0, user: admin_user) }
  let!(:admin_participation1) { create(:admin, protocol: protocol1, user: admin_user) }
  let!(:author_participation0) { create(:author, protocol: protocol0, user: general_user) }
  let!(:author_participation1) { create(:author, protocol: protocol1, user: general_user) }
  let!(:reference_docx) { create(:reference_docx, protocol: protocol1) }

  background(:each) do
    login_as(current_user, scope: :user)
  end


  feature 'admin user', type: :system do
    let!(:current_user) { admin_user }

    scenario 'create(upload) reference.docx' do
      visit protocol_path(protocol0)
      expect(page).to have_field('reference_docx[file]')

      attach_file 'reference_docx[file]', Rails.root.join('spec', 'fixtures', 'reference.docx')
      click_on 'Upload file'

      expect(page).to have_content('File check (Download)')
    end

    skip 'show(download) reference.docx (not work with headless)' do
      visit protocol_path(protocol1)
      expect(page).to have_content('File check (Download)')

      click_on 'File check (Download)'
      wait_for_download
      expect(downloads('*.docx').size).to eq 1
    end

    skip 'update reference.docx (not work with headless)' do
      visit protocol_path(protocol1)

      attach_file 'reference_docx[file]', Rails.root.join('spec', 'fixtures', 'reference2.docx')
      click_on 'Upload file'

      click_on 'File check (Download)'
      wait_for_download
      expect(downloads('*.docx').size).to eq 1
    end

    scenario 'delete reference.docx' do
      visit protocol_path(protocol1)
      expect(page).to have_content('Delete')

      accept_confirm { click_on 'Delete' }
      expect(page).not_to have_content('Delete')
    end
  end

  feature 'general user', type: :system do
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
