class Email
  include ActiveModel::Model
  attr_accessor :from, :to, :subject, :body
  validates :from, presence: true, email: true
  validates :to, presence: true, email: true
  validates :subject, presence: true
  validates :body, presence: true
end
