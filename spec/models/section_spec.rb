require 'rails_helper'

describe Section do
  describe 'validation' do
    context 'no and seq are unique combination within template' do
      before { create(:section, no: 1, seq: 0) }
      it { expect(build(:section, no: 1, seq: 0)).not_to be_valid }
      it { expect(build(:section, no: 1, seq: 0, template_name: 'new_template')).to be_valid }
    end

    context 'title is presence' do
      it { expect(build(:section, no: 1, seq: 1, title: nil)).not_to be_valid }
      it { expect(build(:section, no: 1, seq: 1, title: 'test')).to be_valid }
    end
  end
end
