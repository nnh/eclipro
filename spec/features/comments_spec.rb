require 'rails_helper'

feature Comment, js: true do
  let(:pi) { create(:user) }
  let(:protocol) { create(:protocol) }
  let(:content) { protocol.contents.find_by(no: '1.1') }
  let!(:comment) { create(:comment, content: content, user: pi, body: 'test comment') }
  let!(:pi_participation) { create(:principal_investigator, protocol: protocol, user: pi) }

  background(:each) do
    login_as(pi, scope: :user)
    visit protocol_content_path(protocol, content)
    click_on 'Comments (1)'
    sleep 1
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
    end

    scenario 'can resolve' do
      click_on 'Resolve'
      sleep 1
      expect(page.body).to have_css 'div.resolve-comment'
    end
  end
end
