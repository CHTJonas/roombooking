# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  has_paper_trail

  private

  def exclusive
    if obtain_pg_lock
      begin
        yield
      ensure
        release_pg_lock
      end
    end
  end

  def obtain_pg_lock
    connection.execute("SELECT pg_advisory_lock(#{self.id});")
  end

  def release_pg_lock
    connection.execute("SELECT pg_advisory_unlock(#{self.id});")
  end

  def connection
    ActiveRecord::Base.connection
  end
end
