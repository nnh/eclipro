class CommentsController < ApplicationController
  load_and_authorize_resource :protocol
  load_and_authorize_resource :content, through: :protocol
  load_and_authorize_resource through: :content

  def index
    set_root_comment
    @comment = @content.comments.build
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.save
    @content.reload
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

    def set_root_comment
      @comments = @content.comments.where(parent_id: nil)
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
