# frozen_string_literal: true

module Roombooking
  module RouteConstraints
    class AdminConstraint
      def matches?(request)
        session = Session.find(request.session[:sid])
        !session.invalidated? && !session.user.blocked? && session.user.admin?
      rescue StandardError
        false
      end
    end
  end
end
