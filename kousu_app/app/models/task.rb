class Task < ApplicationRecord
  belongs_to :project
  has_one :organization, through: :project
  has_many :time_entries, dependent: :nullify
  validates :name, presence: true
end
