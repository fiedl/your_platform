class ProfileFieldsController < ApplicationController

  before_action :load_profileable, :only => [:create, :index]
  load_and_authorize_resource except: :index
  skip_authorization_check only: :index
  respond_to :json, :js
  
  def index
    authorize! :read, @profileable
    
    set_current_title "#{@profileable.title}: #{t(:profile)}"
    set_current_navable @profileable
    set_current_activity :looks_at_profile, @profileable
    set_current_access :signed_in
    set_current_access_text :all_signed_in_users_can_read_this_group_profile
    
    cookies[:group_tab] = "profile"
  end

  def create
    type = secure_profile_field_type || 'ProfileFieldTypes::Custom'
    @profile_field = @profile_field.becomes(type.constantize)
    @profile_field.profileable = @profileable
    @profile_field.label = params[:label] if params[:label].present?
    @profile_field.save if @profile_field.changed?
    respond_to do |format|
      format.js
    end
  end

  def update
    if current_user == @profile_field.profileable
      set_current_activity :manages_own_profile, current_user
    else
      set_current_activity :manages_a_profile, current_user
    end
    
    @profile_field = ProfileField.find(params[:id])
    profile_field_class = ProfileField if @profile_field.type.blank?
    profile_field_class ||= ProfileField.possible_types.find { |possible_type| possible_type.to_s == @profile_field.type }
    if profile_field_class.nil?
      raise "security interrupt: '#{@profile_field.type}' is no permitted profileable object type."
    end
    @profile_field = @profile_field.becomes(profile_field_class)
    updated = @profile_field.update_attributes(params[:profile_field])
    
    # Mark issues to be resolved. Then, they will be rechecked later.
    @profile_field.issues.update_all resolved_at: Time.zone.now
    
    respond_with_bip @profile_field
  end
  
  def show
    @profile_field ||= ProfileField.find params[:id]
    authorize! :read, @profile_field
    
    Issue.scan_object(@profile_field) if params[:scan_for_issues].present?

    render json: @profile_field.to_json(methods: [:display_html, :issues])
  end
  
  def destroy
    respond_with @profile_field.destroy
  end
  
  private
  
  def load_profileable
    @section = params[:section] if params[:section].present?
    
    @profileable ||= @group = Group.find(params[:group_id]) if params[:group_id]
    @profileable ||= @user = (User.find params[:user_id]) if params[:user_id]
      
    @profileable ||= if params[ :profileable_type ].present? && params[ :profileable_id ].present?
      @profileable = secure_profileable_type.constantize.find( params[ :profileable_id ] )
    elsif params[ :profileable_type ].blank? and params[ :profileable_id ].blank?
      raise "Profileable type and id are missing!"
    elsif params[ :profileable_type ].blank?
      raise "Profileable type is missing!"
    else
      raise "Profileable id is missing!"
    end

    return @profileable
  end
  
  def secure_profileable_type
    if not params[:profileable_type].in? ["User", "Group"]
      raise "security interrupt: '#{params[:profileable_type]}' is no permitted profileable object type."
    end
    params[:profileable_type]
  end
  
  def secure_profile_field_type
    if not params[:profile_field][:type].in? ([''] + ProfileField.possible_types.map(&:to_s))
      raise "security interrupt: '#{params[:profile_field][:type]}' is not a permitted profile field type."
    end
    params[:profile_field][:type]
  end

end
