# frozen_string_literal: true

# == Schema Information
#
# Table name: application_settings
#
#  id                    :bigint           not null, primary key
#  auto_approve_bookings :boolean          default(FALSE), not null
#

class ApplicationSetting < ApplicationRecord
  has_paper_trail

  after_create :freeze
  before_save :prevent_changes
  before_update :prevent_changes
  after_update :freeze
  before_destroy :prevent_changes

  @@instance = nil

  def self.instance
    @@instance || self.refresh
  end

  def self.refresh
    @@instance = self.last.freeze || self.create_with_default_settings
  end

  def self.create_with_default_settings
    create! do |settings|
      settings.auto_approve_bookings = false
    end
  end

  def prevent_changes
    unless new_record?
      raise ActiveRecord::ReadOnlyRecord.new 'Application settings cannot be update or deleted. You must insert a new record and refresh the instance.'
    end
  end
end
