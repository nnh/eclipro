require 'rails_helper'

feature Participation do
  let(:admin_user) { create(:user) }
  let(:general_user) { create(:user) }
  let!(:new_user) { create(:user) }
  let(:protocol) { create(:protocol) }
  let!(:pi_participation) { create(:principal_investigator, protocol: protocol, user: admin_user) }
  let!(:author_participation) { create(:author, protocol: protocol, user: general_user) }

  before(:each) do
    login_as(current_user, scope: :user)
    visit protocol_path(protocol)
  end

  shared_examples_for 'can see participation users' do
    it do
      expect(page).to have_content(admin_user.name)
      expect(page).to have_content('Principal investigator')
      expect(page).to have_content(general_user.name)
      expect(page).to have_content('Author')
    end
  end

  context 'admin user' do
    let(:current_user) { admin_user }
    it_should_behave_like 'can see participation users'

    it 'can move to new participation page' do
      expect(page).to have_link('Add member')

      click_on 'Add member'
      expect(current_path).to eq(new_protocol_participation_path(protocol))
    end

    it 'can create new participation' do
      visit new_protocol_participation_path(protocol)
      select new_user.name, from: 'participation[user_id]'
      select 'CoAuthor', from: 'participation[role]'
      click_on 'Add'

      expect(current_path).to eq(protocol_path(protocol))
      expect(page).to have_content(new_user.name)
      expect(page).to have_content('CoAuthor')
    end

    it 'can remove participation, can not remove own participation' do
      expect(page).to have_link('Remove')

      within(:xpath, "//tr[td[contains(., '#{general_user.name}')]]") do
        click_on 'Remove'
      end
      expect(page).not_to have_content(general_user.name)
      expect(page).not_to have_link('Remove')
    end
  end

  context 'general user' do
    let(:current_user) { general_user }
    it_should_behave_like 'can see participation users'

    it 'can not move to new participation' do
      expect(page).not_to have_link('Add member')
    end

    it 'can not remove participation' do
      expect(page).not_to have_link('Remove')
    end
  end
end
