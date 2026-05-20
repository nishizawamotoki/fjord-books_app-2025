# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test '#name_or_email 名前があれば、名前を返す' do
    user = users(:tanaka)
    assert_equal user.name, user.name_or_email
  end

  test '#name_or_email 名前がなければ、メールアドレスを返す' do
    user = users(:sato)
    assert_equal user.email, user.name_or_email
  end
end
