class Assignment < ApplicationRecord
  SOURCES = [ "manual", "canvas_ical" ].freeze

  belongs_to :user

  validates :title, presence: true, length: { maximum: 255 }
  validates :course_name, presence: true, length: { maximum: 255 }
  validates :due_date, presence: true
  validates :estimated_hours, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :source, inclusion: { in: SOURCES }

  def imported_from_canvas?
    source == "canvas_ical"
  end
end
