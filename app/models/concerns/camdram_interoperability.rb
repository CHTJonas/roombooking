# frozen_string_literal: true

module CamdramInteroperability
  extend ActiveSupport::Concern

  included do
    after_create_commit :warm_cache!
    validates :camdram_id, numericality: { only_integer: true,
                                           greater_than: 0 }, uniqueness: { message: 'entity already exists' }
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

  # Clears the cached value of the entity's name when its Camdram ID is updated.
  def camdram_id=(cid)
    Rails.cache.delete("#{cache_key}/name") if cid != camdram_id
    super(cid)
  end

  # Returns the name of the entity by querying the Camdram API. This method
  # gets called quite a lot so let's cache the result indefinitely to avoid
  # instantiating a Camdram object each time. The cache can then be refreshed
  # by a background job.
  def name(refresh_cache: false)
    Rails.cache.fetch("#{cache_key}/name", expires_in: nil, force: refresh_cache) do
      camdram_object.try(:name)
    end
  end

  # Returns the entity's external URL on Camdram.
  def url
    Roombooking::CamdramApi.url_for(camdram_object)
  end

  # Queues a background job to refresh the entity's cached data from Camdram.
  def warm_cache!
    global_id = to_global_id.to_s
    CamdramEntityCacheWarmupJob.perform_async(global_id)
  end
end
