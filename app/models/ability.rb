class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :create, :read, :update, :destroy, to: :crud
    alias_action :create, :update, :destroy, to: :cud
    alias_action :read, :update, :destroy, to: :rud
    alias_action :read, :update, to: :ru
    alias_action :index, :read, to: :ir
    can :read, TechnicalOrder
    can :read, Tool
    if user.admin?
      can :manage, :all
      can :view_all_techlogs, Techlog
    elsif user.chief_maintenance_officer? or user.squadron_engineering_officer?
      can :manage, Aircraft
      can :manage, FlyingLog
      can :manage, Techlog
      can :manage, FlyingPlan      
      can :manage, User      
      can :manage, Inspection
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
      can :crud, ScheduledInspection
      can :defer_inspection, ScheduledInspection
      # can :apply_extention, ScheduledInspection
      can :cancel_extention, ScheduledInspection
      can :start_inspection, ScheduledInspection
      can :approve_extension, Techlog
      can :view_open_techlogs, Techlog
      can :update_completed, Techlog
    elsif user.master_control?      
      can :read, Aircraft
      can :get_aircrafts, Aircraft
      can :generate_report, Aircraft 
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
      can :view_open_techlogs, Techlog
      can :start_inspection, ScheduledInspection
      can :apply_extention, ScheduledInspection
      can :crud, ScheduledInspection
      can :view_781, Aircraft # view 781 forms on aircraft detail page
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
      can :logistics_techlog, Techlog
      can :rud, Techlog
    elsif user.dms_controller?
      can :read, Aircraft
      can :crud, TechnicalOrder
    elsif user.data_repo_controller?
      can :read, Aircraft
      can :generate_report, Aircraft
      can :report, Aircraft
      can :view_781, Aircraft
    end
  end
end
