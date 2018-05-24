require 'rails_helper'

feature Section, js: true do
  let(:system_admin_user) { create(:user, system_admin: true) }
  let(:general_user) { create(:user) }
  let!(:section) { create(:section) }

  background(:each) do
    login_as(current_user, scope: :user)
    visit sections_path
  end

  feature 'system admin user' do
    let!(:current_user) { system_admin_user }

    scenario 'show sections' do
      expect(page).to have_content(Section.all.sample.title)
    end

    scenario 'show section' do
      within(:xpath, "//tr[td[contains(., '#{section.title}')]]") do
        click_on 'Details'
      end
      expect(current_path).to eq section_path(section)
    end

    scenario 'update section' do
      within(:xpath, "//tr[td[contains(., '#{section.title}')]]") do
        click_on 'Edit'
      end
      expect(current_path).to eq edit_section_path(section)

      fill_in 'section[title]', with: 'edited title'
      click_on 'Update Section'
      expect(current_path).to eq(section_path(section))
      expect(page).to have_content('edited title')
    end
  end

  feature 'general user' do
    let!(:current_user) { general_user }

    scenario 'not show sections' do
      expect(current_path).to eq root_path
    end

    scenario 'not show section' do
      visit section_path(section)
      expect(current_path).to eq root_path
    end

    scenario 'not update section' do
      visit edit_section_path(section)
      expect(current_path).to eq root_path
    end
  end
end
