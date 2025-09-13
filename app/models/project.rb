class Project < ApplicationRecord
  belongs_to :organization
  has_many :tasks, dependent: :destroy
  has_many :time_entries, dependent: :nullify
  validates :name, presence: true
end
