class CurrentUserController < ApplicationController
  def set_current_user_locale
    current_user.update_attributes! locale: params[:locale]
    redirect_back(fallback_location: root_path)
  end
end
