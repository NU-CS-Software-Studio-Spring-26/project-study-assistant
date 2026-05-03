class Assignment < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :course_name, presence: true
  validates :due_date, presence: true
  validates :estimated_hours, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
