# frozen_string_literal: true

require 'application_system_test_case'

class ReportsTest < ApplicationSystemTestCase
  setup do
    visit root_url
    fill_in 'Eメール', with: users(:tanaka).email
    fill_in 'パスワード', with: 'foobar'
    click_button 'ログイン'
    assert_text 'ログインしました'
  end

  test '日報を作成する' do
    visit reports_url
    click_link '日報の新規作成'
    fill_in 'タイトル', with: '日報作成のテスト用日報'
    fill_in '内容', with: '日報の作成をテストするのための日報です。'
    click_button '登録する'
    assert_text '日報が作成されました。'
    assert_text '日報作成のテスト用日報'
  end

  test '日報を更新する' do
    visit edit_report_path(reports(:tanaka_report).id)
    fill_in 'タイトル', with: '田中の日報改'
    fill_in '内容', with: '更新後の田中の日報です。'
    click_button '更新する'
    assert_text '日報が更新されました。'
    assert_text '田中の日報改'
  end

  test '日報を削除する' do
    visit report_path(reports(:tanaka_report).id)
    click_button 'この日報を削除'
    assert_text '日報が削除されました。'
  end
end
