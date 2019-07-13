# frozen_string_literal: true

class ContactFormSubmission
  include ActiveRecord::Validations

  attr_accessor :from, :subject, :message

  validates :from, presence: true, email: true
  validates :subject, presence: true
  validates :message, presence: true

  def initialize(params = {})
    @from = params['from']
    @subject = params['subject']
    @message = params['message']
  end

  def new_record?
    true
  end

  def self._reflect_on_association(*args); end

  def send!
    ContactFormMailer.deliver_async.send_to_management(from, subject, message)
  end
end
