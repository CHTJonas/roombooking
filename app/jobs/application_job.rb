class ApplicationJob < ActiveJob::Base
  queue_as :jobs
end
