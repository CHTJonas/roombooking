namespace :roombooking do
  desc 'Wipe all data and install Roombooking afresh'
  task install: :environment do
    ActiveRecord::Base.connection.execute <<-'SQL'
CREATE OR REPLACE FUNCTION pg_search_dmetaphone(text) RETURNS text LANGUAGE SQL IMMUTABLE STRICT AS $function$
  SELECT array_to_string(ARRAY(SELECT dmetaphone(unnest(regexp_split_to_array($1, E'\\s+')))), ' ')
$function$;
    SQL
  end

  desc 'Upgrade Roombooking to the latest version'
  task upgrade: :environment do; end

  task protect: :environment do
    ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK'] = 1.to_s
    print 'Are you sure you wish to (re)install the ADC Room Booking System from scratch? (type uppercase YES): '
    unless (STDIN.gets.chomp == 'YES')
      puts 'Good thing I asked! Quitting...'
      exit 1
    end
  end

  Rake::Task['roombooking:install'].enhance ['roombooking:protect', 'db:drop', 'db:create', 'db:schema:load', 'db:seed', 'assets:clobber', 'assets:precompile']
  Rake::Task['roombooking:upgrade'].enhance ['db:migrate', 'assets:clobber', 'assets:precompile']
end
