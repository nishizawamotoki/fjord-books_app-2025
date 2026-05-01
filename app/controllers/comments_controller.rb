class CommentsController < ApplicationController
  before_action :set_comment, only: :destroy
  before_action :authorize_user!, only: :destroy
  def create
    if params[:book_id]
      @book = Book.find(params.expect(:book_id))
    else
      @report = Report.find(params.expect(:report_id))
    end
    @commentable = @book || @report
    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @commentable, notice: "Comment was successfully created." 
    else
      view = params[:book_id] ? 'books/show' : 'reports/show'
      @comments = @commentable.comments.includes(:user)
      render view, status: :unprocessable_entity
    end
  end

  def destroy
    commentable = @comment.commentable
    @comment.destroy!
    redirect_to commentable, status: :see_other, notice: 'コメントが削除されました'
  end

  private

  def set_comment
    @comment = Comment.find(params.expect(:id))
  end

  def comment_params
    params.require(:comment).permit(:content)
  end

  def authorize_user!
    redirect_to root_path, alert: "権限がありません" unless @comment.user_id == current_user.id
  end
end
