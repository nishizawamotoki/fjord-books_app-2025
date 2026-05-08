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
end
