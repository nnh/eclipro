class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_locale

  def set_locale
    I18n.locale = extract_locale_from_accept_language_header
    # I18n.locale = current_user&.locale || extract_locale_from_accept_language_header
  end

  private

    def extract_locale_from_accept_language_header
      request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first == 'ja' ? 'ja' : 'en'
    rescue NoMethodError
      'en'
    end
end
