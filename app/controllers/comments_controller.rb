class CommentsController < ApplicationController
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
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
