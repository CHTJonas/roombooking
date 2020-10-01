# frozen_string_literal: true

module Roombooking
  module RouteConstraints
    class AdminConstraint
      def matches?(request)
        sesh_id = request.session[:sesh_id]
        return false unless sesh_id.present?

        session = Session.find(sesh_id)
        return false unless session.present? && !session.invalidated?

        user = session.user
        !user.blocked? && user.admin?
      rescue StandardError
        false
      end
    end
  end
end
