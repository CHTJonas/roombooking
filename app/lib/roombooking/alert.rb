module Roombooking
  class Alert
    attr_accessor :class, :message

    def initialize(options = {})
      options.each do |key, value|
        instance_variable_set("@#{key}", value) if self.respond_to?(key)
      end
    end

  end
end
