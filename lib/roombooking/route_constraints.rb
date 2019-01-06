module Roombooking
  class AdminConstraint
    def matches?(request)
      sesh_id = request.session[:sesh_id]
      return false unless sesh_id.present?
      session = Session.find(sesh_id)
      return false unless session.present? && !session.invalidated?
      user = session.user
      return !user.blocked? && user.admin?
    end
  end
end
