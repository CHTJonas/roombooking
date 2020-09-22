class Attendee < ApplicationRecord
  strip_attributes

  has_and_belongs_to_many :bookings

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, email: true

  def to_s
    "#{self.name} <#{self.email}>"
  end

  def self.parse(string)
    captures = /(.+)<(.+)>/.match(string)
    return if captures.blank?
    self.find_or_create_by(email: captures[2]) do |attendee|
      attendee.name = captures[1]
    end
  end
end
