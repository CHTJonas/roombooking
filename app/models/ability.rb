class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :create, :read, :update, :destroy, to: :crud

    can :read, Booking, approved: true # Everyone can view approved bookings.
    can :read, Room # Everyone can view rooms.
    if user.present?  # Additional permissions for logged in users...
      if user.admin?
        can :manage, :all # Administrators can do anything!
        can :approve, Booking # They can also approve bookings.
      else
        can :create, Booking # Users can create new bookings if they are listed as a Camdram admin for the show or society.
        can :crud, Booking, user_id: user.id # Users have full CRUD control of their own bookings.
        can [:read, :update], User, id: user.id # Users have edit control of their own user account.
      end
    end
  end
end
