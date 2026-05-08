# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :set_report, only: %i[edit update destroy]

  def index
    @reports = Report.includes(:user).order(id: :desc).page(params[:page])
  end

  def show
    @report = Report.find(params[:id])
  end

  def new
    @report = Report.new
  end

  def edit; end

  def create
    @report = current_user.reports.new(report_params)

    Report.transaction do
      @report.save!
      new_mentioned_report_ids = mentioned_report_ids(@report.content)
      new_mentioned_report_ids.present? && ReportMention.create!(build_report_mention_params(@report.id, new_mentioned_report_ids))
    end
    redirect_to @report, notice: t('controllers.common.notice_create', name: Report.model_name.human)
  rescue ActiveRecord::RecordInvalid
    @report.errors.add(:base, '日報の作成に失敗しました')
    render :new, status: :unprocessable_entity
  end

  def update
    Report.transaction do
      @report.update!(report_params)

      new_mentioned_report_ids = mentioned_report_ids(@report.content)
      existing_mentioned_report_ids = @report.outgoing_mentions.map(&:mentioned_report_id)

      add_ids = (new_mentioned_report_ids - existing_mentioned_report_ids)
      remove_ids = (existing_mentioned_report_ids - new_mentioned_report_ids)

      add_ids.present? && ReportMention.create!(build_report_mention_params(@report.id, add_ids))
      remove_ids.present? && ReportMention.where(mentioning_report_id: @report.id, mentioned_report_id: remove_ids).destroy_all
    end
    redirect_to @report, notice: t('controllers.common.notice_update', name: Report.model_name.human)
  rescue ActiveRecord::RecordInvalid
    @report.errors.add(:base, '日報の更新に失敗しました')
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

  def mentioned_report_ids(content)
    content.scan(%r{http://localhost:3000/reports/(\d+)}).flatten.map(&:to_i)
  end

  def build_report_mention_params(report_id, mentioned_report_ids)
    mentioned_report_ids.map do |id|
      {
        mentioning_report_id: report_id,
        mentioned_report_id: id
      }
    end
  end
end
