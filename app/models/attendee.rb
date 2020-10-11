# == Schema Information
#
# Table name: attendees
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  email      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Attendee < ApplicationRecord
  strip_attributes

  has_and_belongs_to_many :bookings

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, email: true

  def to_s
    "#{name} <#{email}>"
  end

  def self.parse(string)
    captures = /^(.+) <(.+)>$/.match(string)
    return if captures.blank?

    find_or_create_by(email: captures[2]) do |attendee|
      attendee.name = captures[1]
    end
  end
end
