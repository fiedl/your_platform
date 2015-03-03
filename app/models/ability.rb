# This ability class defines the basic structure for our role-based
# authorization system.
# 
# You can either override it completely or use the following method
# to defined your own rights.
#
#     # app/model/ability.rb
#     require_dependency YourPlatform::Engine.root.join('app/models/ability').to_s
#     
#     module AbilityDefinitions
#       def rights_for_local_admins
#         super
#         can :do, :amazing_things
#       end
#     end
# 
#     class Ability
#       prepend AbilityDefinitions
#     end
#
# For an extensive example, have a look at:
# https://github.com/fiedl/wingolfsplattform/blob/master/app/models/ability.rb
# 
class Ability
  include CanCan::Ability

  def initialize(user, params = {}, options = {})
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities

    # Attention: Check outside whether the user's role allowes that preview!
    # Currently, this is done in ApplicationController#current_ability.
    #
    @preview_as = options[:preview_as] 
    @preview_as = nil if @preview_as.blank?
    @role = options[:role].try(:to_s)
  
    @read_only_mode = options[:read_only_mode]
    @params = params
    @user = user
        
    if user
      if user.global_admin? and view_as?(:global_admin)
        rights_for_global_admins
      end
      if user.admin_of_anything? and view_as?(:admin)
        rights_for_local_admins
      end
      if view_as?([:officer, :admin])
        rights_for_local_officers
      end
      if Role.of(user).global_officer? and view_as?([:global_officer, :officer, :admin])
        rights_for_global_officers
      end
      if user.developer?
        rights_for_developers
      end
      rights_for_signed_in_users
    end
    rights_for_everyone

  end
  
  def view_as?(role)
    (view_as.nil?) or (view_as.to_s == '') or if role.kind_of?(Array)
      view_as.in? role
    else
      view_as == role
    end
  end
  def view_as
    preview_as.try(:to_sym)
  end
  def preview_as
    @preview_as
  end
  def read_only_mode?
    @read_only_mode
  end
  def params
    @params
  end
  def user
    @user
  end
  def role
    @role.try(:to_s)
  end
  
  def rights_for_developers
    can :use, Rack::MiniProfiler
  end
  
  def rights_for_global_admins
    if read_only_mode?
      can :read, :all
      can :index, :all
    else
      can :manage, :all
    end
  end
  
  def rights_for_local_admins
    if not read_only_mode?
      can :manage, Group do |group|
        group.admins_of_self_and_ancestors.include? user
      end
    end
  end
  
  def rights_for_local_officers
    can :export_member_list, Group do |group|
      user.in? group.officers_of_self_and_ancestor_groups
    end
  end
  
  def rights_for_global_officers
    can :export_member_list, Group
    can :create_post_for, Group if not read_only_mode?
  end
      
  def rights_for_signed_in_users
    can :read, :all
    can :accept, :terms_of_use if not read_only_mode?
  end
  
  def rights_for_everyone
    can :read, Page.find_imprint
  end
end
