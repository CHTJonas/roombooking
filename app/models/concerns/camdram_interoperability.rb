# frozen_string_literal: true

module CamdramInteroperability
  extend ActiveSupport::Concern

  included do
    after_create_commit :warm_cache!
    validates :camdram_id,
      numericality: { only_integer: true, greater_than: 0 },
      uniqueness: { message: 'entity already exists' }
  end

  module ClassMethods
    # Creates a Camdram entity model from a Camdram::Base object.
    def create_from_camdram(camdram_base)
      create_from_id(camdram_base.id)
    end

    # Find a Camdram entity model from a Camdram::Base object.
    def find_from_camdram(camdram_base)
      find_by(camdram_id: camdram_base.id)
    end

    # Defines a method that, when called, will return the Camdram API object
    # that the entity references.
    def uses_camdram_client_method(method)
      define_method(:camdram_object) do
        return nil unless camdram_id.present?
        begin
          @camdram_object ||= Roombooking::CamdramApi.with do |client|
            client.send(method, camdram_id).make_orphan
          end
        rescue Camdram::Error::ClientError => e
          response_code = e.cause.code['code']
          if response_code == 404
            return nil
          else
            raise e
          end
        end
      end
    end
  end

  # Clears the memoized camdram_object instance variable.
  def clear_camdram_object!
    @camdram_object = nil
  end

  def name
    camdram_object.try(:name)
  end

  # Returns the entity's canonical URL on Camdram.
  def url
    return nil if camdram_object.nil?
    Roombooking::CamdramApi.base_url + camdram_object.url_slug.chomp('.json')
  end

  # Returns the entity's numerically-identifying URL on Camdram.
  def url_by_id_for
    type = case self
    when CamdramSociety
      "societies"
    when CamdramShow
      "shows"
    when CamdramVenue
      "venues"
    else
      raise "Unknown Camdram entity type"
    end
    "#{Roombooking::CamdramApi.base_url}/#{type}/by-id/#{camdram_id}"
  end

  # Queues a background job to refresh the entity's cached data from Camdram.
  def warm_cache!
    global_id = to_global_id.to_s
    CamdramEntityCacheWarmupJob.perform_async(global_id)
  end

  # Returns the pair of keys used when caching responses from the Camdram API.
  def response_cache_keys
    base_url = Roombooking::CamdramApi.base_url
    key_namespace = Roombooking::CamdramApi::ResponseCacheStore.key_namespace
    [url, url_by_id_for].reject { |u| u.nil? }.map { |u| u.sub(base_url, key_namespace) + '.json'}
  end
end
