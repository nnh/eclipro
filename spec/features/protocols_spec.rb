require 'rails_helper'

feature Protocol, js: true do
  let(:admin_user) { create(:user) }
  let(:general_user) { create(:user) }
  let(:protocol0) { create(:protocol, title: 'Test protocol') }
  let(:protocol1) { create(:protocol, title: 'abcde protocol', status: 'finalized') }
  let(:protocol2) { create(:protocol, title: '12345 protocol') }
  let!(:admin_participation0) { create(:admin, protocol: protocol0, user: admin_user) }
  let!(:admin_participation1) { create(:admin, protocol: protocol1, user: admin_user) }
  let!(:author_participation0) { create(:author, protocol: protocol0, user: general_user) }
  let!(:author_participation1) { create(:author, protocol: protocol1, user: general_user) }

  background(:each) do
    login_as(current_user, scope: :user)
    visit protocols_path
  end

  shared_examples_for 'can see participating protocols' do
    scenario 'all' do
      expect(page).to have_content protocol0.title
      expect(page).to have_content protocol1.title
      expect(page).not_to have_content protocol2.title
    end

    scenario 'with filter' do
      fill_in 'protocol_name_filter', with: 'Test'
      click_on 'Filtering'
      expect(page).to have_content protocol0.title
      expect(page).not_to have_content protocol1.title
    end
  end

  shared_examples_for 'can create new protocol' do
    scenario '(and automaticaly create contents)' do
      click_on 'Create new protocols'
      expect(current_path).to eq new_protocol_path

      select 'General', from: 'protocol[template_name]'
      fill_in 'protocol[title]', with: 'New protocol'
      fill_in 'protocol[protocol_number]', with: 'NP'
      click_on 'Create Protocol'
      expect(current_path).to eq protocol_content_path(Protocol.last, Protocol.last.contents.first)
      expect(page).to have_content 'New protocol'
      expect(Protocol.last.contents.count). to eq Section.reject_specified_sections('General').count
    end
  end

  shared_examples_for 'can move to show protocol page' do
    scenario do
      within(:xpath, "//tr[td[contains(., '#{protocol0.title}')]]") do
        click_on 'Details'
      end
      expect(current_path).to eq protocol_path(protocol0)
    end
  end

  shared_examples_for 'can move to show contents page' do
    scenario do
      find(:xpath, "//tr[td[contains(., '#{protocol0.title}')]]").click
      expect(current_path).to eq protocol_content_path(protocol0, protocol0.contents.first)
    end
  end

  shared_examples_for 'can clone protocol' do
    scenario do
      within(:xpath, "//tr[td[contains(., '#{protocol0.title}')]]") do
        click_on 'Clone'
      end
      expect(current_path).to eq(clone_protocol_path(protocol0))
    end
  end

  shared_examples_for 'moves to export page (status is finalized)' do
    scenario do
      within(:xpath, "//tr[td[contains(., '#{protocol1.title}')]]") do
        click_on 'Export'
      end
      expect(current_path).to eq select_protocol_path(protocol1)
    end
  end

  shared_examples_for 'exports protocol' do
    scenario 'pdf' do
      visit select_protocol_path(protocol1)
      click_on 'Export(.pdf)'

      handle = page.driver.browser.window_handles.last
      page.driver.browser.within_window(handle) do
        expect(page.response_headers['Content-Type']).to eq('application/pdf')
      end
    end
    scenario 'docx' do
      visit select_protocol_path(protocol1)
      click_on 'Export(.docx)'

      handle = page.driver.browser.window_handles.last
      page.driver.browser.within_window(handle) do
        expect(page.response_headers['Content-Type']).to eq('application/vnd.openxmlformats-officedocument.wordprocessingml.document')
      end
    end
    scenario 'selects export_type' do
      visit select_protocol_path(protocol1)
      base_href = export_protocol_path(protocol1, format: 'pdf')
      choose 'export_type_english'
      expect(page).to have_link(nil, href: "#{base_href}?type=english")
      choose 'export_type_japanese'
      expect(page).to have_link(nil, href: "#{base_href}?type=japanese")
      choose 'export_type_both'
      expect(page).to have_link(nil, href: "#{base_href}?type=both")
    end
  end

  feature 'admin user' do
    let(:current_user) { admin_user }
    it_should_behave_like 'can see participating protocols'
    it_should_behave_like 'can create new protocol'
    it_should_behave_like 'can move to show protocol page'
    it_should_behave_like 'can move to show contents page'
    it_should_behave_like 'can clone protocol'
    it_should_behave_like 'moves to export page (status is finalized)'
    it_should_behave_like 'exports protocol'

    scenario 'can edit protocol' do
      visit(protocol_path(protocol0))
      expect(page).to have_link('Edit', count: 3)

      all(:link, 'Edit')[1].click
      expect(current_path).to eq edit_protocol_path(protocol0)

      fill_in 'protocol[title]', with: 'Edit protocol'
      click_on 'Update Protocol'
      expect(current_path).to eq protocol_path(protocol0)
      expect(page).to have_content 'Edit protocol'
    end

    scenario 'can export protocol (in details page)' do
      visit(protocol_path(protocol0))
      expect(page).to have_link 'Export'

      click_on 'Export'
      expect(current_path).to eq select_protocol_path(protocol0)
    end

    scenario 'can change status to finalized' do
      visit(protocol_path(protocol0))
      expect(page).to have_link 'Finalize'

      click_on 'Finalize'
      expect(page).not_to have_link 'Finalized'
      expect(page).to have_link 'Reinstate'
    end

    scenario 'can change status to from "finalized" to "in_progress"' do
      visit(protocol_path(protocol1))
      expect(page).to have_link 'Reinstate'

      click_on 'Reinstate'
      expect(page).not_to have_link 'Reinstate'
      expect(page).to have_link 'Finalize'
    end
  end

  feature 'general user' do
    let(:current_user) { general_user }
    it_should_behave_like 'can see participating protocols'
    it_should_behave_like 'can create new protocol'
    it_should_behave_like 'can move to show protocol page'
    it_should_behave_like 'can move to show contents page'
    it_should_behave_like 'can clone protocol'
    it_should_behave_like 'moves to export page (status is finalized)'
    it_should_behave_like 'exports protocol'

    scenario 'can not edit protocol' do
      visit(protocol_path(protocol0))
      expect(page).to have_link('Edit', count: 1)
    end

    scenario 'can not export protocol (in details page)' do
      visit(protocol_path(protocol0))
      expect(page).not_to have_link 'Export(.pdf)'
      expect(page).not_to have_link 'Export(.docx)'
    end

    scenario 'can not change status to finalized' do
      visit(protocol_path(protocol0))
      expect(page).not_to have_link 'Finalize'
    end

    scenario 'can not change status to from "finalized" to "in_progress"' do
      visit(protocol_path(protocol1))
      expect(page).not_to have_link 'Reinstate'
    end
  end
end
