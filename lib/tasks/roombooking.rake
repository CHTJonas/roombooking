namespace :roombooking do
  desc 'Install roombooking afresh'
  task install: :environment do
    ActiveRecord::Base.connection.execute <<-'SQL'
CREATE OR REPLACE FUNCTION pg_search_dmetaphone(text) RETURNS text LANGUAGE SQL IMMUTABLE STRICT AS $function$
  SELECT array_to_string(ARRAY(SELECT dmetaphone(unnest(regexp_split_to_array($1, E'\\s+')))), ' ')
$function$;
    SQL
  end

  task protect: :environment do
    print 'Are you sure you wish to (re)install the ADC Room Booking System from scratch? (type uppercase YES): '
    unless (STDIN.gets.chomp == 'YES')
      puts 'Good thing I asked! Quitting...'
      exit 1
    end
  end

  Rake::Task['roombooking:install'].enhance ['roombooking:protect', 'db:drop', 'db:create', 'db:schema:load', 'db:seed']
end
