# frozen_string_literal: true

class Report < ApplicationRecord
  validates :title, :content, presence: true
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy
end
