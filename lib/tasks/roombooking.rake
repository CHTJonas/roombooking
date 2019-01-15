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

  desc 'Prevent accidental database operations'
  task protect: :environment do
    puts Rainbow('WARNING!!!').red
    print Rainbow(
%{Are you sure you wish to (re)install the ADC Room
Booking System from scratch? (type uppercase YES): }).yellow
    unless (STDIN.gets.chomp == 'YES')
      puts 'Good thing I asked! Quitting...'
      exit 1
    end
    ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK'] = '1'
  end

  desc 'Backup the Postgres database using pg_dump'
  task backup: :environment do
    require 'open3'
    puts Rainbow('Dumping Postgres database...').blue
    file_path = "#{Rails.root}/db/backup/roombooking_#{Rails.env}_#{DateTime.now.to_i}.pgdump"
    pgsql_args = "-Fc roombooking_#{Rails.env}"
    Open3.popen3("pg_dump #{pgsql_args}") do |stdin, stdout, stderr, wait_thr|
      file = File.new(file_path, 'w')
      IO.copy_stream(stdout, file)
      file.close
      puts stderr.read
    end
    puts Rainbow('Done!').green
  end

  Rake::Task['roombooking:install'].enhance ['roombooking:protect', 'db:drop', 'db:create', 'db:schema:load', 'db:seed', 'assets:clobber', 'assets:precompile']
  Rake::Task['roombooking:upgrade'].enhance ['db:migrate', 'assets:clobber', 'assets:precompile']
end
