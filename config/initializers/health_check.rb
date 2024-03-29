# frozen_string_literal: true

HealthCheck.setup do |config|
  config.uri = 'health_check'
  config.success = "I'm alright, Jack!"

  config.max_age = 0

  config.http_status_for_error_text = 500
  config.http_status_for_error_object = 500

  config.standard_checks = ['database', 'migrations', 'camdram']
  config.full_checks = ['database', 'migrations', 'camdram', 'cache', 'redis', 'sidekiq-redis']

  # Redis runs locally without any auth
  config.redis_password = nil

  config.add_custom_check('camdram') do
    # This block should return a blank string on
    # success and a non-blank string on failure.
    begin
      user = Roombooking::CamdramApi.with { |client| client.user.make_orphan }
      if user.id == 3807
        ''
      else
        'Invalid response from the Camdram API'
      end
    rescue Exception
      'Failed to make a request to the Camdram API'
    end
  end
end
