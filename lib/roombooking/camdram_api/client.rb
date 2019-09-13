# frozen_string_literal: true

module Roombooking
  module CamdramApi
    class Client
      def initialize(*args, &block)
        @client = Camdram::Client.new(*args, &block)
      end

      def inspect
        "#<#{self.class}>"
      end

      def respond_to_missing?(method, *args)
        @client.methods.include? method || super
      end

      def method_missing(method, *args)
        if @client.methods.include? method
          begin
            @client.send(method, *args)
          rescue OAuth2::Error => e
            raise Roombooking::CamdramApi::CamdramError.new, e unless e.code.is_a? Hash
            http_status = e.code['code']
            raise Roombooking::CamdramApi::CamdramError.new, e unless http_status.is_a? Integer
            if http_status.between?(400, 499)
              raise Roombooking::CamdramApi::ClientError.new, e
            elsif http_status.between?(500, 599)
              raise Roombooking::CamdramApi::ServerError.new, e
            else
              raise Roombooking::CamdramApi::CamdramError.new, e
            end
          rescue Faraday::TimeoutError => e
            raise Roombooking::CamdramApi::TimeoutError.new, e
          rescue Faraday::ConnectionFailed => e
            if e.wrapped_exception.class == Net::OpenTimeout
              raise Roombooking::CamdramApi::TimeoutError.new, e
            else
              raise Roombooking::CamdramApi::CamdramError.new, e
            end
          rescue => e
            raise Roombooking::CamdramApi::CamdramError.new, e
          end
        else
          super
        end
      end
    end
  end
end
