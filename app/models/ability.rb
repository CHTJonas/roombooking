class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # setup as a guest if need be
    if user.admin?
      can :manage, :all # admins can do anything
    else
      if !user.id.nil?
        can :create, Booking # users can create new bookings
        can :manage, Booking, user_id: user.id # users have full control of their own bookings
        can :manage, User, id: user.id # users have full control of their own user account
      end
      can :read, Booking # users & guests can view all bookings
      can :read, Venue # users & guests can view all venues
    end
  end
end
