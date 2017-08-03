class CommentsController < ApplicationController
  before_action :set_comment, only: [:resolve]
  before_action :set_content

  def index
    @comments = @content.comments
    @comment = @content.comments.build
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.save
    @comments = @content.comments
  end

  def resolve
    @comment.update(comment_params)
    @comments = @content.comments
  end

  def add_comment
    @comment = @content.comments.build
  end

  def add_reply
    @comment = @content.comments.build
  end

  private
    def set_comment
      @comment = Comment.find(params[:id])
    end

    def set_content
      @content = Content.find(params[:content_id])
    end

    def comment_params
      params.require(:comment).permit(:content_id, :user_id, :body, :parent_id, :resolve)
    end
end
