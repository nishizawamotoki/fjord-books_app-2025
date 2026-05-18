# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :set_report, only: %i[edit update destroy]

  def index
    @reports = Report.includes(:user).order(id: :desc).page(params[:page])
  end

  def show
    @report = Report.find(params[:id])
    @mentioned_reports = @report.mentioned_reports.includes(:user)
  end

  def new
    @report = Report.new
  end

  def edit; end

  def create
    @report = current_user.reports.new(report_params)

    Report.transaction do
      @report.save!
      @report.sync_report_mentions!
    end
    redirect_to @report, notice: t('controllers.common.notice_create', name: Report.model_name.human)
  rescue ActiveRecord::RecordInvalid
    @report.errors.add(:base, t('controllers.common.error_create', name: Report.model_name.human))
    render :new, status: :unprocessable_entity
  end

  def update
    Report.transaction do
      @report.update!(report_params)
      @report.sync_report_mentions!
    end
    redirect_to @report, notice: t('controllers.common.notice_update', name: Report.model_name.human)
  rescue ActiveRecord::RecordInvalid
    @report.errors.add(:base, t('controllers.common.error_update', name: Report.model_name.human))
    render :edit, status: :unprocessable_entity
  end

  def destroy
    @report.destroy!

    redirect_to reports_path, status: :see_other, notice: t('controllers.common.notice_destroy', name: Report.model_name.human)
  end

  private

  def set_report
    @report = current_user.reports.find(params[:id])
  end

  def report_params
    params.expect(report: %i[user_id title content])
  end
end
