# == Schema Information
#
# Table name: emails
#
#  id         :bigint           not null, primary key
#  message    :jsonb            not null
#  created_at :datetime
#

class Email < ApplicationRecord
  validates :message, presence: true

  # Creates an Email record from a Mail:Message object.
  def self.create_from_message(msg)
    json = msg.to_json
    create!(message: json)
  end
end
