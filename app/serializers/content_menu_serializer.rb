class ContentMenuSerializer < BaseSerializer
  attributes :id, :seq, :no, :no_seq, :title, :content_url, :editable, :status_icon, :comments_count

  def content_url
    url_helpers.protocol_content_path(object.protocol, object, anchor: :sections)
  end

  def editable
    @instance_options[:ability].can?(:updatable, object) || @instance_options[:ability].can?(:reviewable, object)
  end
end
