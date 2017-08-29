class CommentsController < ApplicationController
  before_action :set_comment, only: [:resolve]
  before_action :set_content, :set_protocol
  load_and_authorize_resource

  def index
    set_root_comment
    @comment = @content.comments.build
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.save
    set_root_comment
  end

  def resolve
    resolve_comments(@comment)
    set_root_comment
  end

  def comment
    @comment = @content.comments.build
  end

  def reply
    @comment = @content.comments.build
    @parent_id = comment_params[:parent_id]
  end

  private
    def set_comment
      @comment = Comment.find(params[:id])
    end

    def set_content
      @content = Content.find(params[:content_id])
    end

    def set_protocol
      @protocol = Protocol.find(params[:protocol_id])
    end

    def set_root_comment
      @comments = @content.comments
      @comments = @comments.reject { |comment| comment.parent_id.present? }
    end

    def resolve_comments(comment)
      replies = Comment.where(parent_id: comment.id)
      replies.each do |reply|
        resolve_comments(reply)
      end
      comment.update(comment_params)
    end

    def comment_params
      params.require(:comment).permit(:content_id, :user_id, :body, :parent_id, :resolve)
    end
end
