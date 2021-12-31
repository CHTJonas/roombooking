# frozen_string_literal: true

ns = Roombooking::InfoCounter.key_namespace
Rails.cache.delete_matched("#{ns}*")
