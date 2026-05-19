# frozen_string_literal: true

class ReportMention < ApplicationRecord
  belongs_to :from_report, class_name: 'Report', foreign_key: :mentioning_report_id, inverse_of: 'outgoing_mentions'
  belongs_to :to_report, class_name: 'Report', foreign_key: :mentioned_report_id, inverse_of: 'incoming_mentions'
end
