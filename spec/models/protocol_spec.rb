require 'rails_helper'

describe Protocol do
  let(:co) { create(:user) }
  let(:author) { create(:user) }
  let(:reviewer) { create(:user) }
  let(:pi) { create(:user) }
  let(:other) { create(:user) }
  let(:protocol) { create(:protocol, principal_investigator: pi, co_authors: [co],
                          authors: [author], reviewers: [reviewer]) }
  let(:protocol2) { create(:protocol) }

  describe 'role' do
    context 'get current_user role' do
      it { expect(protocol.my_role(co)).to eq(I18n.t('activerecord.enum.protocol.role.co_author')) }
      it { expect(protocol.my_role(author)).to eq(I18n.t('activerecord.enum.protocol.role.author')) }
      it { expect(protocol.my_role(reviewer)).to eq(I18n.t('activerecord.enum.protocol.role.reviewer')) }
      it { expect(protocol.my_role(pi)).to eq(I18n.t('activerecord.attributes.protocol.principal_investigator')) }
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

  # TODO:
  describe 'get sections' do
    xit 'updatable' do
    end

    xit 'reviewable' do
    end
  end

  context 'has_reviewer?' do
    it { expect(protocol.has_reviewer?).to eq(true) }
    it { expect(protocol2.has_reviewer?).to eq(false) }
  end
end
