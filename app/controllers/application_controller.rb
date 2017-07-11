class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?

  def set_locale
    I18n.locale = current_user&.locale || extract_locale_from_accept_language_header
  end

  private

    def extract_locale_from_accept_language_header
      request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first == 'ja' ? 'ja' : 'en'
    rescue NoMethodError
      'en'
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up) do |user|
        user.permit(:name, :email, :password, :password_confirmation, :current_password)
      end
      devise_parameter_sanitizer.permit(:account_update) do |user|
        user.permit(:name, :email, :password, :password_confirmation, :current_password)
      end
    end
end
