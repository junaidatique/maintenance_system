class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :create, :read, :update, :destroy, to: :crud
    alias_action :create, :update, :destroy, to: :cud
    alias_action :index, :read, to: :ir
    if user.admin?
      can :manage, :all
    elsif user.master_control?
      puts 'here 123'
      can [:read, :update], Aircraft
    end
  end
end
