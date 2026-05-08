# frozen_string_literal: true

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
      redirect_to @commentable, notice: t('controllers.common.notice_create', name: Comment.model_name.human)
    else
      view = params[:book_id] ? 'books/show' : 'reports/show'
      @comments = @commentable.comments.includes(:user)
      render view, status: :unprocessable_entity
    end
  end

  def destroy
    commentable = @comment.commentable
    @comment.destroy!
    redirect_to commentable, status: :see_other, notice: t('controllers.common.notice_destroy', name: Comment.model_name.human)
  end

  private

  def set_comment
    @comment = Comment.find(params.expect(:id))
  end

  def comment_params
    params.expect(comment: :content)
  end

  def authorize_user!
    redirect_to root_path, alert: t('controllers.common.alert_authorization_failure') if @comment.user_id != current_user.id
  end
end
