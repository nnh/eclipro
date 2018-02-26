class ContentSerializer < ActiveModel::Serializer
  attributes :id, :no, :title
  has_many :versions

  class VersionSerializer < ActiveModel::Serializer
    attributes :whodunnit, :created_at, :revert_url, :compare_url

    def created_at
      object.created_at.strftime('%Y-%m-%d %H:%M:%S UTC')
    end

    def revert_url
      content = Content.find(object.item_id)
      if Ability.new(@instance_options[:user], '').can? :edit, content
        Rails.application.routes.url_helpers.revert_protocol_content_path(content.protocol, content,
                                                                          lock_version: content.lock_version)
      else
        ''
      end
    end

    def compare_url
      content = Content.find(object.item_id)
      Rails.application.routes.url_helpers.compare_protocol_content_path(content.protocol, content)
    end
  end
end
