require 'rails_helper'

feature 'Header:', type: :system do
  feature 'Always,', type: :system do
    scenario 'user can move to root' do
      visit root_path
      expect(page).to have_content('eclipro')

      click_on 'eclipro'
      expect(current_path).to eq(root_path)
    end
  end

  feature 'Before sign in,', type: :system do
    scenario 'user can see "Sign in" button and move to sign in page' do
      visit root_path
      expect(page).to have_content('Sign in')

      click_on 'Sign in'
      expect(current_path).to eq(new_user_session_path)
    end
  end

  feature 'After sign in,', type: :system do
    let(:user) { create(:user) }

    background(:each) do
      login_as(user, scope: :user)
      visit root_path
    end

    scenario 'user can see headers' do
      expect(page).to have_content('View protocols')
      expect(page).to have_content('Create new protocols')
      expect(page).to have_content('Help')
      expect(page).to have_content(user.name)
      expect(page).to have_content(user.email)
      expect(page).to have_content('Edit')
      expect(page).to have_content('Sign out')
      expect(page).to have_content('Language')
      expect(page).to have_content('日本語')
      expect(page).to have_content('English')
    end

    scenario 'user can move to user edit page' do
      click_on "#{user.name}(#{user.email})"
      click_on 'Edit'
      expect(current_path).to match(edit_user_registration_path)
    end

    scenario 'user can sign out' do
      click_on "#{user.name}(#{user.email})"
      click_on 'Sign out'
      expect(current_path).to eq(root_path)
      expect(page).not_to have_content('View protocols')
    end

    scenario 'user can change language' do
      click_on 'Language'
      click_on '日本語'
      expect(page).to have_content('プロトコルを見る')
    end
  end
end
