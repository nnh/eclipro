require 'rails_helper'

describe Protocol do
  let(:co) { create(:user) }
  let(:author) { create(:user) }
  let(:reviewer) { create(:user) }
  let(:pi) { create(:user) }
  let(:other) { create(:user) }

  let(:protocol) { create(:protocol) }
  let(:protocol2) { create(:protocol) }

  let(:sections) { Section.parent_items(protocol.template_name) }
  let!(:pi_participation) { create(:principal_investigator, protocol: protocol, user: pi, sections: sections) }
  let!(:co_participation) { create(:co_author, protocol: protocol, user: co, sections: sections) }
  let!(:author_participation) { create(:author, protocol: protocol, user: author, sections: [0, 1]) }
  let!(:reviewer_participation) { create(:reviewer, protocol: protocol, user: reviewer, sections: [2, 3]) }

  describe 'validation' do
    context 'title is presence' do
      it { expect(build(:protocol, title: nil)).not_to be_valid }
      it { expect(build(:protocol, title: 'test')).to be_valid }
    end
  end

  describe 'role' do
    context 'get current_user role' do
      it { expect(protocol.my_role(co)).to eq('CoAuthor') }
      it { expect(protocol.my_role(author)).to eq('Author') }
      it { expect(protocol.my_role(reviewer)).to eq('Reviewer') }
      it { expect(protocol.my_role(pi)).to eq('Principal investigator') }
    end

    context 'judgment user role' do
      it { expect(protocol.co_author?(co)).to eq(true) }
      it { expect(protocol.author?(co)).to eq(false) }
      it { expect(protocol.reviewer?(co)).to eq(false) }
      it { expect(protocol.principal_investigator?(co)).to eq(false) }
      it { expect(protocol.co_author?(author)).to eq(false) }
      it { expect(protocol.author?(author)).to eq(true) }
      it { expect(protocol.reviewer?(author)).to eq(false) }
      it { expect(protocol.principal_investigator?(author)).to eq(false) }
      it { expect(protocol.co_author?(reviewer)).to eq(false) }
      it { expect(protocol.author?(reviewer)).to eq(false) }
      it { expect(protocol.reviewer?(reviewer)).to eq(true) }
      it { expect(protocol.principal_investigator?(reviewer)).to eq(false) }
      it { expect(protocol.co_author?(pi)).to eq(false) }
      it { expect(protocol.author?(pi)).to eq(false) }
      it { expect(protocol.reviewer?(pi)).to eq(false) }
      it { expect(protocol.principal_investigator?(pi)).to eq(true) }
    end

    context 'whether the user is participating or not' do
      it { expect(protocol.participant?(co)).to eq(true) }
      it { expect(protocol.participant?(author)).to eq(true) }
      it { expect(protocol.participant?(reviewer)).to eq(true) }
      it { expect(protocol.participant?(pi)).to eq(true) }
      it { expect(protocol.participant?(other)).to eq(false) }
    end
  end

  describe 'get sections' do
    context 'updatable' do
      let(:all_sections) { Section.reject_specified_sections(protocol.template_name).pluck(:no) }
      it { expect(protocol.updatable_sections(co)).to eq all_sections }
      it { expect(protocol.updatable_sections(author)).to eq ['0', '1', '1.1', '1.2', '1.3'] }
      it { expect(protocol.updatable_sections(reviewer)).to eq [] }
      it { expect(protocol.updatable_sections(pi)).to eq all_sections }
    end

    context 'reviewable' do
      let(:all_sections) { Section.reject_specified_sections(protocol.template_name).pluck(:no) }
      it { expect(protocol.reviewable_sections(co)).to eq all_sections }
      it { expect(protocol.reviewable_sections(author)).to eq [] }
      it { expect(protocol.reviewable_sections(reviewer)).to eq ['2', '2.1', '2.2', '2.3', '3'] }
      it { expect(protocol.reviewable_sections(pi)).to eq all_sections }
    end
  end
end
