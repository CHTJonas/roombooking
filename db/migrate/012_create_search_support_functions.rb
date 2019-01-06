class CreateSearchSupportFunctions < ActiveRecord::Migration[5.2]
  def change
    execute 'CREATE EXTENSION unaccent;'
    execute 'CREATE EXTENSION fuzzystrmatch;'
    execute 'CREATE EXTENSION pg_trgm;'
    execute <<-'SQL'
CREATE OR REPLACE FUNCTION pg_search_dmetaphone(text) RETURNS text LANGUAGE SQL IMMUTABLE STRICT AS $function$
  SELECT array_to_string(ARRAY(SELECT dmetaphone(unnest(regexp_split_to_array($1, E'\\s+')))), ' ')
$function$;
    SQL
  end
end
