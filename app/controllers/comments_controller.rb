class CommentsController < ApplicationController
  def create
    @commentable = params[:book_id] ? Book.find(params[:book_id]) : Report.find(params[:report_id])
    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user

    if @commentable.save
      redirect_to @commentable, notice: "Comment was successfully created." 
    else
      path = params[:book_id] ? 'books/show' : 'reports/show'
      render path, status: :unprocessable_entity
    end
  end

  def destroy
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
