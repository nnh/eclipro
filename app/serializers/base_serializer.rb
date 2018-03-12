class BaseSerializer < ActiveModel::Serializer
  def created_at
    object.created_at.strftime('%Y-%m-%d %H:%M:%S UTC')
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
