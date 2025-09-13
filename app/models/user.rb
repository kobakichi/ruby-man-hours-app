class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
\n  has_many :memberships, dependent: :destroy
has_many :organizations, through: :memberships
has_many :time_entries, dependent: :destroy
end
