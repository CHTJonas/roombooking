class LogEvent < ActiveRecord::Base
  belongs_to :logable, polymorphic: true

  enum outcome: [ :failure, :success ]
  enum interface: [ :web ]

  # Log a new event
  def self.log(logable_object, outcome, action=nil, interface=nil, ip=nil, user_agent=nil)
    event = self.new
    event.logable = logable_object
    event.outcome = outcome
    event.action = action
    event.interface = interface
    event.ip = ip
    event.user_agent = user_agent
    if event.save
      event
    else
      raise event.errors.full_messages.to_sentence
    end
  end

  # Delete old event data
  def self.prune(max_age = 6.months)
    self.where("created_at <= :end_date", { end_date: max_age.ago }).delete_all
  end
end
