require 'rails_helper'

describe CurrentUserController, type: :controller do
  describe '#set_current_user_locale' do
    it 'user can change locale' do
      user = create(:user)
      sign_in(user)
      put :set_current_user_locale, params: { locale: 'ja' }
      user.reload
      expect(user.locale).to eq('ja')
    end
  end
end
