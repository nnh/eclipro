class CommentSerializer < BaseSerializer
  attributes :id, :body, :resolve, :created_at, :replyable, :resolve_url
  has_one :user
  has_many :replies

  def content
    object.content
  end

  def protocol
    content.protocol
  end

  def replyable
    object.resolve? ? false : true
  end

  def resolve_url
    if object.parent_id.nil? && !object.resolve?
      url_helpers.resolve_protocol_content_comment_path(protocol, content, object)
    else
      ''
    end
  end

  def replies
    comments = Comment.where(parent_id: object.id)
    if comments.any?
      ActiveModel::Serializer::CollectionSerializer.new(comments, serializer: CommentSerializer)
    else
      []
    end
  end

  class UserSerializer < ActiveModel::Serializer
    attributes :name
  end
end
