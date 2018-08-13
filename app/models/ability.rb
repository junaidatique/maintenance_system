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
    elsif user.chief_maintenance_officer? or user.squadron_engineering_officer?
      can :manage, Aircraft
      can :manage, FlyingLog
      can :manage, Techlog
      can :manage, FlyingPlan      
      can :manage, User      
      can :manage_addl_logs, Techlog
      cannot :update_fuel, Techlog

      can :release_flight, FlyingLog
      can :view_logs, FlyingLog # view techlogs, deffered logs and limitation logs.
      can :update_sortie, FlyingLog # update sortie code in case of non satisfactory
      
      # can't do anything about the pilot work
      cannot :bookout_flight, FlyingLog      
      cannot :bookin_flight, FlyingLog
      # cannot :update_work_unit_code, FlyingLog

      can :autocomplete, FlyingPlan   
      can :cancel, FlyingLog   
      can :view_781, Aircraft # view 781 forms on aircraft detail page
      can :view_flight_techlogs, FlyingLog
      can :manage, AutherizationCode
      can :generate_report, Techlog
    elsif user.master_control?      
      can :read, Aircraft
      can :get_aircrafts, Aircraft
      can :crud, FlyingLog
      can :crud, Techlog            
      can :update_work_unit_code, FlyingLog      
      can :update_autherization_code, Techlog
      can :manage, FlyingPlan      
      can :autocomplete, FlyingPlan 
      can :update_sortie, FlyingLog
      can :autocomplete_codes, AutherizationCode      
      can :manage, Inspection
      can :cancel, FlyingLog
      can :view_flight_techlogs, FlyingLog
    elsif user.inst_fitt?
      can :read, Aircraft
      can :ru, FlyingLog
      can :crud, Techlog
      can :autocomplete, FlyingPlan            
    elsif user.eng_fitt?
      can :read, Aircraft
      can :ru, FlyingLog
      can :crud, Techlog    
      can :update_fuel, Techlog  
      can :autocomplete, FlyingPlan      
    elsif user.afr_fitt?
      can :read, Aircraft
      can :ru, FlyingLog
      can :crud, Techlog
      can :autocomplete, FlyingPlan      
    elsif user.ro_fitt?
      can :read, Aircraft
      can :ru, FlyingLog
      can :crud, Techlog
      can :autocomplete, FlyingPlan          
    elsif user.elect_fitt?
      can :read, Aircraft
      can :ru, FlyingLog
      can :crud, Techlog
    elsif user.gen_fitt?
      can :read, Aircraft
      can :ru, FlyingLog
      can :crud, Techlog
      can :crud, Tool
      can :crud, RequestedTool
    elsif user.pilot?
      can :read, Aircraft
      can [:read, :update], FlyingLog
      can :bookout_flight, FlyingLog
      can :bookin_flight, FlyingLog
      can :crud, Techlog
      can :view_logs, FlyingLog
    elsif user.log_asst?
      can :read, Aircraft
      can :rud, Techlog
      can :crud, Tool
      can :crud, RequestedTool
    elsif user.logistics?
      can :read, Aircraft
      can :read, Part
      can :cru, Part
      can :rud, Techlog
    end
  end
end
