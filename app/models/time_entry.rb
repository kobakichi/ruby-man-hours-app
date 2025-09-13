class TimeEntry < ApplicationRecord
  belongs_to :organization
  belongs_to :user
  belongs_to :project
  belongs_to :task, optional: true
  belongs_to :approved_by, class_name: 'User', optional: true

  validates :work_date, presence: true
  validates :minutes, numericality: { only_integer: true, greater_than: 0 }

  scope :between, ->(from, to) { where(work_date: from..to) }

  def hours
    (minutes.to_f / 60.0).round(2)
  end
end
