# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  private

  def obtain_pg_lock
    connection.select_value("SELECT pg_try_advisory_lock(#{lock_tuple});")
  end

  def wait_for_pg_lock
    connection.execute("SELECT pg_advisory_lock(#{lock_tuple});")
    nil
  end

  def release_pg_lock
    connection.select_value("SELECT pg_advisory_unlock(#{lock_tuple});")
  end

  def lock_tuple
    @lock_tuple ||= "#{self.class.pg_oid},#{self.id}"
  end

  def connection
    ActiveRecord::Base.connection
  end

  def self.pg_oid
    @oid ||= ActiveRecord::Base.connection.select_value("SELECT oid FROM pg_class WHERE relname = '#{self.table_name}';")
  end
end
