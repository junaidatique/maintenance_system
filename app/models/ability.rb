class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :create, :read, :update, :destroy, to: :crud
    alias_action :create, :update, :destroy, to: :cud
    alias_action :read, :update, :destroy, to: :rud
    alias_action :read, :update, to: :ru
    alias_action :index, :read, to: :ir
    if user.admin?
      can :manage, :all
    elsif user.chief_maintenance_officer?      
      can :manage, Aircraft
      can :manage, FlyingLog
      can :manage, Techlog
      can :manage, FlyingPlan      
      can :manage_addl_logs, Techlog
      cannot :update_fuel, Techlog  
      cannot :update_work_unit_code, Techlog      
      can :update_flying_log, FlyingLog
      can :release_flight, FlyingLog
      can :view_logs, FlyingLog
      can :update_sortie, FlyingLog
      can :view_781, FlyingLog
      cannot :bookout_flight, FlyingLog      
      cannot :update_work_unit_code, FlyingLog
    elsif user.master_control?      
      can :read, Aircraft
      can :crud, FlyingLog
      can :crud, Techlog
      can :read, FlyingPlan
      can :update_work_unit_code, FlyingLog
      can :update_work_unit_code, Techlog
    elsif user.crew_cheif?
      can :read, Aircraft
      can :ru, FlyingLog
      can :crud, Techlog
      can :update_fuel, Techlog
    elsif user.inst_fitt?
      can :read, Aircraft
      can :ru, FlyingLog
      can :crud, Techlog      
    elsif user.eng_fitt?
      can :read, Aircraft
      can :ru, FlyingLog
      can :crud, Techlog      
    elsif user.afr_fitt?
      can :read, Aircraft
      can :ru, FlyingLog
      can :crud, Techlog
    elsif user.ro_fitt?
      can :read, Aircraft
      can :ru, FlyingLog
      can :crud, Techlog    
    elsif user.elect_fitt?
      can :read, Aircraft
      can :ru, FlyingLog
      can :crud, Techlog
    elsif user.gen_fitt?
      can :read, Aircraft
      can :ru, FlyingLog
      can :crud, Techlog
    elsif user.pilot?
      can :read, Aircraft
      can [:read, :update], FlyingLog
      can :bookout_flight, FlyingLog
      can :bookin_flight, FlyingLog
      can :crud, Techlog
      can :view_logs, FlyingLog
    elsif user.log_asst?
      can :read, Aircraft
      can :crud, Tool
      can :rud, Techlog
      can :crud, RequestedTool
    elsif user.logistics?
      can :read, Aircraft
      can :read, Part
      can :cru, Part
      can :rud, Techlog
    end
  end
end
