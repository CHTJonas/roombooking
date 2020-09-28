# frozen_string_literal: true

# See https://github.com/Casecommons/pg_search/issues/446
module PgSearch
  mattr_accessor :unaccent_function
  self.unaccent_function = 'unaccent'
end
