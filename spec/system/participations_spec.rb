require 'rails_helper'

feature Participation, type: :system do
  let(:admin_user) { create(:user) }
  let(:general_user) { create(:user) }
  let!(:new_user) { create(:user) }
  let(:protocol) { create(:protocol) }
  let!(:admin_participation) { create(:admin, protocol: protocol, user: admin_user) }
  let!(:author_participation) { create(:author, protocol: protocol, user: general_user, sections: [0]) }

  background(:each) do
    login_as(current_user, scope: :user)
    visit protocol_path(protocol)
  end

  shared_examples_for 'can see participation users' do
    scenario do
      expect(page).to have_content(admin_user.name)
      expect(page).to have_content('Admin')
      expect(page).to have_content(general_user.name)
      expect(page).to have_content('Author')
    end
  end

  feature 'admin user', type: :system do
    let(:current_user) { admin_user }
    it_should_behave_like 'can see participation users'

    scenario 'can move to new participation page' do
      expect(page).to have_link('Add member')

      click_on 'Add member'
      expect(current_path).to eq(new_protocol_participation_path(protocol))
    end

    scenario 'can create new participation' do
      visit new_protocol_participation_path(protocol)
      select new_user.name, from: 'participation[user_id]'
      select 'Admin', from: 'participation[role]'
      click_on 'Save'

      expect(current_path).to eq(protocol_path(protocol))
      expect(page).to have_content(new_user.name)
      expect(page).to have_content('Admin')
    end

    scenario 'can remove participation, can not remove own participation' do
      expect(page).to have_link('Remove')

      within(:xpath, "//tr[td[contains(., '#{general_user.name}')]]") do
        accept_confirm { click_on 'Remove' }
      end
      expect(page).not_to have_content(general_user.name)
      expect(page).not_to have_link('Remove')
    end

    scenario 'can move to edit participation page' do
      within(:xpath, "//tr[td[contains(., '#{general_user.name}')]]") do
        expect(page).to have_link('Edit')
        click_on 'Edit'
      end
      expect(current_path).to eq(edit_protocol_participation_path(protocol, author_participation))
    end

    scenario 'can edit participation' do
      visit edit_protocol_participation_path(protocol, author_participation)

      select 'Reviewer', from: 'participation[role]'
      check 'participation_sections_1'
      check 'participation_sections_2'
      click_on 'Save'

      expect(page).not_to have_content('Author')
      expect(page).to have_content('Reviewer')
      expect(page).to have_content('0, 1, 2')
    end
  end

  feature 'general user', type: :system do
    let(:current_user) { general_user }
    it_should_behave_like 'can see participation users'

    scenario 'can not move to new participation' do
      expect(page).not_to have_link('Add member')
    end

    scenario 'can not remove participation' do
      expect(page).not_to have_link('Remove')
    end

    scenario 'can not move to edit participation page' do
      within(:xpath, "//tr[td[contains(., '#{admin_user.name}')]]") do
        expect(page).not_to have_link('Edit')
      end
    end
  end
end
