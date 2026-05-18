# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy

  # 自分の日報が「言及している」関係
  has_many :outgoing_mentions, class_name: 'ReportMention', foreign_key: :mentioning_report_id, inverse_of: 'from_report', dependent: :destroy
  has_many :mentioning_reports, through: :outgoing_mentions, source: :to_report

  # 自分の日報が「言及されている」関係
  has_many :incoming_mentions, class_name: 'ReportMention', foreign_key: :mentioned_report_id, inverse_of: 'to_report', dependent: :destroy
  has_many :mentioned_reports, through: :incoming_mentions, source: :from_report

  validates :title, presence: true
  validates :content, presence: true

  def editable?(target_user)
    user == target_user
  end

  def created_on
    created_at.to_date
  end

  def sync_report_mentions!
    new_mentioned_report_ids = mentioned_report_ids
    existing_mentioned_report_ids = outgoing_mentions.map(&:mentioned_report_id)

    add_ids = (new_mentioned_report_ids - existing_mentioned_report_ids)
    remove_ids = (existing_mentioned_report_ids - new_mentioned_report_ids)

    ReportMention.create!(build_report_mention_params(id, add_ids)) if add_ids.present?
    ReportMention.where(mentioning_report_id: id, mentioned_report_id: remove_ids).destroy_all if remove_ids.present?
  end

  private

  def mentioned_report_ids
    content.scan(%r{http://localhost:3000/reports/(\d+)}).flatten.map(&:to_i).uniq
  end

  def build_report_mention_params(report_id, mentioned_report_ids)
    Report.where(id: mentioned_report_ids).pluck(:id).map do |id|
      {
        mentioning_report_id: report_id,
        mentioned_report_id: id
      }
    end
  end
end
