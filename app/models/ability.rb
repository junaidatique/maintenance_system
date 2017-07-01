class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :create, :read, :update, :destroy, to: :crud
    alias_action :create, :update, :destroy, to: :cud
    alias_action :index, :read, to: :ir
    if user.admin?
      can :manage, :all
    elsif user.master_control?
      can [:read, :update], Aircraft
      cannot :crud, NonFlyingDay
      can :crud, FlyingLog
    elsif user.crew_cheif?
      can [:read, :update], FlyingLog
      can :crud, Techlog
    elsif user.pilot?
      can [:read, :update], FlyingLog
      can :crud, Techlog
    end
  end
end
