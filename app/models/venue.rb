class Venue < ApplicationRecord
  has_many :booking

  validates :name, presence: true
end
