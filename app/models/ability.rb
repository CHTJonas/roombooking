class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Booking # Everyone can view bookings.
    can :read, Venue # Everyone can view venues.
    if user.present?  # Additional permissions for logged in users...
      if user.admin?
        can :manage, :all # Administrators can do anything!
      else
        can :create, Booking # Users can create new bookings if they are listed as a Camdram admin for the show or society.
        can :manage, Booking, user_id: user.id # Users have full control of their own bookings
        can :manage, User, id: user.id # Users have full control of their own user account.
      end
    end
  end
end
