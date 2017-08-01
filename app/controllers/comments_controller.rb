class CommentsController < ApplicationController
  before_action :set_comment, only: [:update, :destroy, :resolve]
  before_action :set_content, only: :index

  def index
    @comments = @content.comments
    @comment = @content.comments.build
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.save
    @comments = @comment.content.comments
  end

  def update
    @comment.update(comment_params)
    @comments = @comment.content.comments
  end

  def destroy
    @comment.destroy
    @comments = @comment.content.comments
  end

  def resolve
    @comment.update(comment_params)
    @comments = @comment.content.comments
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
