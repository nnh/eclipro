require 'rails_helper'

feature Section, js: true do
  let(:admin_user) { create(:user) }
  let(:general_user) { create(:user) }
  let!(:section) { create(:section) }

  background(:each) do
    login_as(current_user, scope: :user)
    visit sections_path
  end

  # TODO: ability

  feature 'editable user' do
    let!(:current_user) { admin_user }

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

  feature 'not editable user' do
    let!(:current_user) { general_user }

    scenario 'show sections' do
      expect(page).to have_content(Section.all.sample.title)
    end

    scenario 'show section' do
      within(:xpath, "//tr[td[contains(., '#{section.title}')]]") do
        click_on 'Details'
      end
      expect(current_path).to eq section_path(section)
    end

    # scenario 'can not update section' do
    #   within(:xpath, "//tr[td[contains(., '#{section.title}')]]") do
    #     expect(page).not_to have_content('Edit')
    #   end
    #
    #   visit edit_section_path(section)
    #   expect(current_path).to eq root_path
    # end
  end
end
