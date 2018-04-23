require 'rails_helper'

feature Content, js: true do
  let(:admin) { create(:user) }
  let(:author) { create(:user) }
  let(:other_author) { create(:user) }
  let(:reviewer) { create(:user) }
  let(:other_reviewer) { create(:user) }
  let(:protocol) { create(:protocol) }
  let(:content) { protocol.contents.find_by(no: 0) }
  let!(:admin_participation) { create(:admin, protocol: protocol, user: admin) }
  let!(:author_participation0) { create(:author, protocol: protocol, user: author, sections: [0, 1, 2]) }
  let!(:author_participation1) { create(:author, protocol: protocol, user: other_author, sections: [3]) }
  let!(:reviewer_participation0) { create(:reviewer, protocol: protocol, user: reviewer, sections: [0, 1, 2]) }
  let!(:reviewer_participation1) { create(:reviewer, protocol: protocol, user: other_reviewer, sections: [3]) }

  let!(:status_new) do
    protocol.contents.find_by(no: 1, seq: 1)
  end
  let!(:in_progress) do
    content = protocol.contents.find_by(no: 2, seq: 1)
    content.update_attributes(status: 'in_progress', body: 'before body')
    content.update_attributes(status: 'in_progress', body: 'after body')
    content
  end
  let!(:under_review) do
    content = protocol.contents.find_by(no: 2, seq: 2)
    content.update_attributes(status: 'under_review')
    content
  end
  let!(:final) do
    content = protocol.contents.find_by(no: 2, seq: 3)
    content.update_attributes(status: 'final')
    content
  end

  background(:each) do
    login_as(current_user, scope: :user)
  end

  shared_examples_for 'can see contents' do
    it do
      visit protocol_content_path(protocol, content)
      expect(current_path).to eq protocol_content_path(protocol, content)
    end
  end

  shared_examples_for 'can update content' do
    it do
      visit protocol_content_path(protocol, content)
      expect(page).to have_button 'Update Content'

      page.execute_script("tinyMCE.editors[0].setContent('new body text')")
      click_on 'Update Content'
      expect(page).to have_content('new body text')
    end
  end

  shared_examples_for 'can not update content' do
    it do
      visit protocol_content_path(protocol, content)
      expect(page).not_to have_button 'Update Content'
    end
  end

  shared_examples_for 'can change status from "New / In Progress" to "Under Review"' do
    it 'new' do
      visit protocol_content_path(protocol, content)
      expect(page).to have_link 'Ready for Review'

      click_on 'Ready for Review'
      expect(page).to have_content 'Status: Under Review'
    end
    it 'in progress' do
      visit protocol_content_path(protocol, in_progress)
      expect(page).to have_link 'Ready for Review'

      click_on 'Ready for Review'
      expect(page).to have_content 'Status: Under Review'
    end
  end

  shared_examples_for 'can not change status from "New / In Progress" to "Under Review"' do
    it 'new' do
      visit protocol_content_path(protocol, content)
      expect(page).not_to have_link 'Ready for Review'
    end
    it 'in progress' do
      visit protocol_content_path(protocol, in_progress)
      expect(page).not_to have_link 'Ready for Review'
    end
  end

  shared_examples_for 'can change status from "Under Review" to "Final"' do
    it do
      visit protocol_content_path(protocol, under_review)
      expect(page).to have_link 'Review Completed'

      click_on 'Review Completed'
      expect(page).to have_content 'Status: Final'
    end
  end

  shared_examples_for 'can not change status from "Under Review" to "Final"' do
    it do
      visit protocol_content_path(protocol, under_review)
      expect(page).not_to have_link 'Review Completed'
    end
  end

  shared_examples_for 'can change status from "Under Review" to "In Progress"' do
    it do
      visit protocol_content_path(protocol, under_review)
      expect(page).to have_link 'Rework Needed'

      click_on 'Rework Needed'
      expect(page).to have_content 'Status: In Progress'
    end
  end

  shared_examples_for 'can not change status from "Under Review" to "In Progress"' do
    it do
      visit protocol_content_path(protocol, under_review)
      expect(page).not_to have_link 'Rework Needed'
    end
  end

  shared_examples_for 'can change status from "Final" to "In Progress"' do
    it do
      visit protocol_content_path(protocol, final)
      expect(page).to have_link 'Rework Needed'

      click_on 'Rework Needed'
      expect(page).to have_content 'Status: In Progress'
    end
  end

  shared_examples_for 'can not change status from "Final" to "In Progress"' do
    it do
      visit protocol_content_path(protocol, final)
      expect(page).not_to have_link 'Rework Needed'
    end
  end

  shared_examples_for 'can see history and compare' do
    it do
      visit protocol_content_path(protocol, in_progress)
      expect(page).to have_link 'History'

      click_on 'History'
      sleep 1
      expect(page).to have_css 'div.history-index'
      expect(page).to have_button 'Compare'

      first(:button, 'Compare').click
      sleep 1
      within 'div.history-compare' do
        expect(page).to have_content in_progress.body
      end
    end
  end

  shared_examples_for 'can revert' do
    it do
      visit protocol_content_path(protocol, in_progress)

      click_on 'History'
      sleep 1
      expect(page).to have_link 'Revert'

      first(:link, 'Revert').click
      sleep 1
      expect(page).to have_content 'before body'
    end
  end

  shared_examples_for 'can not revert' do
    it do
      visit protocol_content_path(protocol, in_progress)

      click_on 'History'
      sleep 1
      expect(page).not_to have_link 'Revert'
    end
  end

  describe 'admin' do
    let(:current_user) { admin }
    it_should_behave_like 'can see contents'
    it_should_behave_like 'can update content'
    it_should_behave_like 'can change status from "New / In Progress" to "Under Review"'
    it_should_behave_like 'can change status from "Under Review" to "Final"'
    it_should_behave_like 'can change status from "Under Review" to "In Progress"'
    it_should_behave_like 'can change status from "Final" to "In Progress"'
    it_should_behave_like 'can see history and compare'
    it_should_behave_like 'can revert'
  end

  describe 'author' do
    let(:current_user) { author }
    it_should_behave_like 'can see contents'
    it_should_behave_like 'can update content'
    it_should_behave_like 'can change status from "New / In Progress" to "Under Review"'
    it_should_behave_like 'can not change status from "Under Review" to "Final"'
    it_should_behave_like 'can change status from "Under Review" to "In Progress"'
    it_should_behave_like 'can change status from "Final" to "In Progress"'
    it_should_behave_like 'can see history and compare'
    it_should_behave_like 'can revert'
  end

  describe 'other section author' do
    let(:current_user) { other_author }
    it_should_behave_like 'can see contents'
    it_should_behave_like 'can not update content'
    it_should_behave_like 'can not change status from "New / In Progress" to "Under Review"'
    it_should_behave_like 'can not change status from "Under Review" to "Final"'
    it_should_behave_like 'can not change status from "Under Review" to "In Progress"'
    it_should_behave_like 'can not change status from "Final" to "In Progress"'
    it_should_behave_like 'can see history and compare'
    it_should_behave_like 'can not revert'
  end

  describe 'reviewer' do
    let(:current_user) { reviewer }
    it_should_behave_like 'can see contents'
    it_should_behave_like 'can not update content'
    it_should_behave_like 'can not change status from "New / In Progress" to "Under Review"'
    it_should_behave_like 'can change status from "Under Review" to "Final"'
    it_should_behave_like 'can change status from "Under Review" to "In Progress"'
    it_should_behave_like 'can change status from "Final" to "In Progress"'
    it_should_behave_like 'can see history and compare'
    it_should_behave_like 'can not revert'
  end

  describe 'other section reviewer' do
    let(:current_user) { other_reviewer }
    it_should_behave_like 'can see contents'
    it_should_behave_like 'can not update content'
    it_should_behave_like 'can not change status from "New / In Progress" to "Under Review"'
    it_should_behave_like 'can not change status from "Under Review" to "Final"'
    it_should_behave_like 'can not change status from "Under Review" to "In Progress"'
    it_should_behave_like 'can not change status from "Final" to "In Progress"'
    it_should_behave_like 'can see history and compare'
    it_should_behave_like 'can not revert'
  end
end
