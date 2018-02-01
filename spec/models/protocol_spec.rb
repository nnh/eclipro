require 'rails_helper'

describe Protocol do
  let(:admin) { create(:user) }
  let(:author) { create(:user) }
  let(:reviewer) { create(:user) }
  let(:other) { create(:user) }

  let(:protocol) { create(:protocol) }
  let(:protocol2) { create(:protocol) }

  let(:sections) { Section.parent_items(protocol.template_name) }
  let!(:admin_participation) { create(:admin, protocol: protocol, user: admin, sections: sections) }
  let!(:author_participation) { create(:author, protocol: protocol, user: author, sections: [0, 1]) }
  let!(:reviewer_participation) { create(:reviewer, protocol: protocol, user: reviewer, sections: [2, 3]) }

  describe 'validation' do
    context 'template_name is presence' do
      it { expect(build(:protocol, template_name: nil)).not_to be_valid }
      it { expect(build(:protocol, title: 'General')).to be_valid }
    end

    context 'title is presence' do
      it { expect(build(:protocol, title: nil)).not_to be_valid }
      it { expect(build(:protocol, title: 'test')).to be_valid }
    end

    context 'protocol_number is presence' do
      it { expect(build(:protocol, title: 'test', protocol_number: nil)).not_to be_valid }
      it { expect(build(:protocol, title: 'test', protocol_number: 't')).to be_valid }
    end
  end

  describe 'role' do
    context 'get current_user role' do
      it { expect(protocol.my_role(admin)).to eq('Admin') }
      it { expect(protocol.my_role(author)).to eq('Author') }
      it { expect(protocol.my_role(reviewer)).to eq('Reviewer') }
    end

    context 'judgment user role' do
      it { expect(protocol.admin?(admin)).to eq(true) }
      it { expect(protocol.author?(admin)).to eq(false) }
      it { expect(protocol.reviewer?(admin)).to eq(false) }
      it { expect(protocol.admin?(author)).to eq(false) }
      it { expect(protocol.author?(author)).to eq(true) }
      it { expect(protocol.reviewer?(author)).to eq(false) }
      it { expect(protocol.admin?(reviewer)).to eq(false) }
      it { expect(protocol.author?(reviewer)).to eq(false) }
      it { expect(protocol.reviewer?(reviewer)).to eq(true) }
    end

    context 'whether the user is participating or not' do
      it { expect(protocol.participant?(admin)).to eq(true) }
      it { expect(protocol.participant?(author)).to eq(true) }
      it { expect(protocol.participant?(reviewer)).to eq(true) }
      it { expect(protocol.participant?(other)).to eq(false) }
    end
  end

  describe 'get sections' do
    context 'updatable' do
      let(:all_sections) { Section.by_template(protocol.template_name).pluck(:no) }
      it { expect(protocol.updatable_sections(admin)).to eq all_sections }
      it { expect(protocol.updatable_sections(author)).to eq ['0', '1', '1.1', '1.2', '1.3'] }
      it { expect(protocol.updatable_sections(reviewer)).to eq [] }
    end

    context 'reviewable' do
      let(:all_sections) { Section.by_template(protocol.template_name).pluck(:no) }
      it { expect(protocol.reviewable_sections(admin)).to eq all_sections }
      it { expect(protocol.reviewable_sections(author)).to eq [] }
      it { expect(protocol.reviewable_sections(reviewer)).to eq ['2', '2.1', '2.2', '2.3', '3'] }
    end
  end
end
