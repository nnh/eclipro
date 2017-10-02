require 'rails_helper'

feature 'Header:' do
  context 'Always,' do
    scenario 'user can move to root' do
      visit root_path
      expect(page).to have_content('eclipro')

      click_on 'eclipro'
      expect(current_path).to eq(root_path)
    end
  end

  context 'Before sign in,' do
    scenario 'user can see "sign in" button and move to sign in page' do
      visit root_path
      expect(page).to have_content(I18n.t('layouts.application.sign_in'))

      click_on I18n.t('layouts.application.sign_in')
      expect(current_path).to eq(new_user_session_path)
    end
  end

  context 'After sign in,' do
    let(:user) { create(:user) }

    before(:each) do
      login_as(user, scope: :user)
      visit root_path
    end

    scenario 'user can see headers' do
      expect(page).to have_content(I18n.t('layouts.application.view_protocols'))
      expect(page).to have_content(I18n.t('layouts.application.create_new_protocols'))
      expect(page).to have_content(user.name)
      expect(page).to have_content(user.email)
      expect(page).to have_content(I18n.t('layouts.application.edit'))
      expect(page).to have_content(I18n.t('layouts.application.sign_out'))
      expect(page).to have_content(I18n.t('layouts.application.language'))
      expect(page).to have_content(I18n.t('layouts.application.japanese'))
      expect(page).to have_content(I18n.t('layouts.application.english'))
    end

    scenario 'user can move to user edit page' do
      click_on I18n.t('layouts.application.edit')
      expect(current_path).to match(edit_user_registration_path)
    end

    scenario 'user can sign out' do
      click_on I18n.t('layouts.application.sign_out')
      expect(current_path).to eq(root_path)
      expect(page).not_to have_content(I18n.t('layouts.application.view_protocols'))
    end

    scenario 'user can change language' do
      click_on I18n.t('layouts.application.japanese')
      expect(page).to have_content(I18n.t('layouts.application.view_protocols', locale: :ja))
    end
  end
end
