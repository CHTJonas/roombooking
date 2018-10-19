web: bundle exec unicorn -c config/unicorn.rb
worker: bundle exec sidekiq -t 25 -q roombooking_production_default
mailer: bundle exec sidekiq -t 25 -q roombooking_production_mailers
