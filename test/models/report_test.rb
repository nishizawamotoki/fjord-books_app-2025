# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  setup do
    @report = reports(:tanaka_report)
  end

  test '#editable? 投稿者には日報の編集権限がある' do
    assert @report.editable?(users(:tanaka))
  end

  test '#editable? 投稿者以外には日報の編集権限がない' do
    assert_not @report.editable?(users(:sato))
  end

  test '#created_on 作成日時を Date オブジェクトにして返す' do
    assert_equal Date.new(2026, 5, 14), @report.created_on
  end

  test '#save_mentions 日報保存時に、過去の言及関係が削除され、新しい言及関係が作成される' do
    sato_report = reports(:sato_report)
    yamada_report = reports(:yamada_report)
    watanabe_report = reports(:watanabe_report)

    @report.content = "#{mentioned_report_url(sato_report.id)} と #{mentioned_report_url(yamada_report.id)} を参考にしました。"
    @report.save
    assert ReportMention.exists?(mentioning: @report, mentioned: sato_report)
    assert ReportMention.exists?(mentioning: @report, mentioned: yamada_report)

    @report.content = "#{mentioned_report_url(watanabe_report.id)} と #{mentioned_report_url(yamada_report.id)} を参考にしました。"
    @report.save
    assert_not ReportMention.exists?(mentioning: @report, mentioned: sato_report)
    assert ReportMention.exists?(mentioning: @report, mentioned: yamada_report)
    assert ReportMention.exists?(mentioning: @report, mentioned: watanabe_report)
  end

  test '#save_mentions 自分自身の日報に言及した場合、言及関係は作成されない' do
    @report.content = mentioned_report_url(@report.id)
    @report.save
    assert_not ReportMention.exists?(mentioning: @report, mentioned: @report)
  end

  def mentioned_report_url(report_id)
    "http://localhost:3000/reports/#{report_id}"
  end
end
