class CommentsController < ApplicationController
  def create
    @book = Book.find(params[:book_id])
    @comment = @book.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @book, notice: "Comment was successfully created." 
    else
      render 'books/show', status: :unprocessable_entity 
    end
  end

  def destroy
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
