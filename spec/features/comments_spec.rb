require 'rails_helper'

feature Comment, js: true do
  let(:user) { create(:user) }
  let(:protocol) { create(:protocol) }
  let(:content) { protocol.contents.find_by(no: 1, seq: 1) }
  let!(:comment) { create(:comment, content: content, user: user, body: 'test comment') }
  let!(:admin_participation) { create(:admin, protocol: protocol, user: user) }

  background(:each) do
    ActionController::Base.allow_forgery_protection = true
    login_as(user, scope: :user)
    visit protocol_content_path(protocol, content)
    click_on 'Comments (1)'
    sleep 1
  end

  after do
    ActionController::Base.allow_forgery_protection = false
  end

  feature 'participating user' do
    scenario 'can comment' do
      click_on 'Comment'
      sleep 1
      fill_in 'comment[body]', with: 'new comment'
      sleep 1
      click_on 'Create Comment'
      sleep 1
      expect(page.body).to have_content 'new comment'
    end

    scenario 'can reply' do
      click_on 'Reply'
      sleep 1
      fill_in 'comment[body]', with: 'new reply'
      sleep 1
      click_on 'Create Comment'
      sleep 1
      expect(page.body).to have_content 'new reply'
      within first('.comment') do
        expect(page.body).to have_css '.comment'
      end
    end

    scenario 'can resolve' do
      click_on 'Resolve'
      sleep 1
      expect(page.body).to have_css 'div.resolve-comment'
    end
  end
end
