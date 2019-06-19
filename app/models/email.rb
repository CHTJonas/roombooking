# == Schema Information
#
# Table name: emails
#
#  id         :bigint           not null, primary key
#  from       :string           not null
#  to         :string           not null
#  subject    :string           not null
#  body       :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Email < ApplicationRecord
  validates :from, presence: true, email: true
  validates :to, presence: true, email: true
  validates :subject, presence: true
  validates :body, presence: true
end
