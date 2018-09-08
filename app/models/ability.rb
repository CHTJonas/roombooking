class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Booking # everyone can view bookings
    can :read, Venue # everyone can view venues
    if user.present?  # additional permissions for logged in users
      if user.admin?
        can :manage, :all # admins can do anything
      else
        can :create, Booking # users can create new bookings
        can :manage, Booking, user_id: user.id # users have full control of their own bookings
        can :manage, User, id: user.id # users have full control of their own user account
      end
    end
  end
end
