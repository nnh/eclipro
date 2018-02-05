class CommentsController < ApplicationController
  load_and_authorize_resource :protocol
  load_and_authorize_resource :content, through: :protocol
  load_and_authorize_resource through: :content

  def index
    set_root_comment
    html = render_to_string partial: 'index', formats: :html,
                            locals: { protocol: @protocol, content: @content, comments: @comments }
    render json: { html: html }
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.save
    @content.reload

    set_root_comment
    button = render_to_string partial: 'contents/comment_button', formats: :html,
                              locals: { protocol: @protocol, content: @content }
    comments = render_to_string partial: 'comments', formats: :html,
                                locals: { protocol: @protocol, content: @content, comments: @comments }
    render json: { no: @content.no.tr('.', '-'), button: button, comments: comments }
  end

  def resolve
    resolve_comments(@comment)

    set_root_comment
    html = render_to_string partial: 'comments', formats: :html,
                            locals: { protocol: @protocol, content: @content, comments: @comments }
    render json: { html: html }
  end

  def reply
    parent_id = comment_params[:parent_id]

    html = render_to_string partial: 'form', formats: :html,
                            locals: { protocol: @protocol, content: @content, parent_id: parent_id }
    render json: { parent_id: parent_id, html: html }
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
