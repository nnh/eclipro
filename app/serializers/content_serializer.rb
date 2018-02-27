class ContentSerializer < BaseSerializer
  attributes :id, :no, :title
  has_many :versions

  class VersionSerializer < BaseSerializer
    attributes :whodunnit, :created_at, :revert_url, :compare_url

    def revert_url
      content = Content.find(object.item_id)
      if Ability.new(@instance_options[:user], '').can? :edit, content
        url_helpers.revert_protocol_content_path(content.protocol, content, lock_version: content.lock_version)
      else
        ''
      end
    end

    def compare_url
      content = Content.find(object.item_id)
      url_helpers.compare_protocol_content_path(content.protocol, content)
    end
  end
end
