class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :create, :read, :update, :destroy, to: :crud
    alias_action :create, :update, :destroy, to: :cud
    alias_action :read, :update, :destroy, to: :rud
    alias_action :index, :read, to: :ir
    if user.admin?
      can :manage, :all
    elsif user.chief_maintenance_officer?
      can :manage, :all
    elsif user.master_control?
      can [:read, :update], Aircraft
      cannot :crud, NonFlyingDay
      can :crud, FlyingLog
      can :crud, Techlog
    elsif user.engineer?
      can [:read, :update], Aircraft
      cannot :crud, NonFlyingDay
      can :crud, FlyingLog
      can :crud, Techlog
      can :crud, User
    elsif user.crew_cheif?
      can :read, FlyingLog
      can :update, FlyingLog do |flying_log|
        !flying_log.is_fuel_filled
      end        
      can :crud, Techlog
    elsif user.central_tool_store?
      can :crud, Tool
      can :rud, Techlog
    elsif user.logistics_supervisor?
      can :crud, Part
      can :rud, Techlog
    elsif user.radio_technician?
      can :read, FlyingLog
      can :crud, Techlog    
    elsif user.electro_mac_technician?
      can :read, FlyingLog
      can :crud, Techlog
    elsif user.pilot?
      can [:read, :update], FlyingLog
      can :crud, Techlog
    end
  end
end
