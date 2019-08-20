# frozen_string_literal: true

namespace :roombooking do
  namespace :search do
    desc 'Install the Postgres full-text search dmetaphone function'
    task setup: :environment do
      puts Rainbow('Installing full-text search dmetaphone function...').blue
      ActiveRecord::Base.connection.execute %{
CREATE OR REPLACE FUNCTION pg_search_dmetaphone(text) RETURNS text LANGUAGE SQL IMMUTABLE STRICT AS $function$
SELECT array_to_string(ARRAY(SELECT dmetaphone(unnest(regexp_split_to_array($1, E'\\s+')))), ' ') $function$;}
    end
  end

  desc 'Wipe all data and install Roombooking afresh'
  task install: :environment do; end

  desc 'Upgrade Roombooking to the latest version'
  task upgrade: :environment do; end

  desc 'Setup the Docker development environment'
  task docker: :environment do; end

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
    file_path = Rails.root.join('db', 'backup', "roombooking_#{Rails.env}_#{DateTime.now.to_i}.pgdump")
    return_value = nil
    Open3.popen3('pg_dump', '-Fc', "roombooking_#{Rails.env}") do |stdin, stdout, stderr, wait_thr|
      file = File.new(file_path, 'w')
      IO.copy_stream(stdout, file)
      print Rainbow(stderr.read).yellow
      return_value = wait_thr.value
      file.close
    end
    if return_value.success?
      puts Rainbow('Done!').green
    else
      puts Rainbow('Failed!').red
    end
  end

  Rake::Task['roombooking:install'].enhance ['roombooking:protect', 'db:drop', 'db:create', 'db:schema:load', 'db:seed', 'assets:clobber', 'assets:precompile', 'webpacker:compile', 'search:setup']
  Rake::Task['roombooking:upgrade'].enhance ['db:migrate', 'assets:precompile', 'webpacker:compile']
  Rake::Task['roombooking:docker'].enhance ['db:prepare', 'db:seed', 'yarn:install', 'search:setup']
end
