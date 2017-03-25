class ProfileFieldsController < ApplicationController

  before_action :load_profileable, :only => [:create, :index]
  load_and_authorize_resource except: :index
  skip_authorization_check only: :index

  before_action :log_public_activity_for_profileable, only: [:destroy]
  after_action :log_public_activity_for_profileable, only: [:create, :update]

  respond_to :json, :js, :html

  def index
    authorize! :manage, @profileable

    set_current_title "#{@profileable.title}: #{t(:profile_fields_maintenance_view)}"
    set_current_navable @profileable
    set_current_access :admin
    set_current_access_text :only_global_admins_can_access_this

    @profile_fields = @profileable.profile_fields
  end

  def create
    type = secure_profile_field_type || 'ProfileFields::Custom'
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
    updated = @profile_field.update_attributes(profile_field_params)

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

  def profile_field_params
    params
      .require(:profile_field)
      .permit(:label, :type, :value, :key, :profileable_id, :profileable_type, :needs_review)
      .permit(:postal_address)
  end

  def load_profileable
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

  # The PublicActivity::Activity is logged by the application controller. But it is not
  # very helpful to know that profile field 1234 has been changed or deleted. Therefore,
  # we log additional information here.
  #
  def log_public_activity_for_profileable
    PublicActivity::Activity.create(
      trackable: @profile_field.profileable,
      key: "#{action_name} profile field",
      owner: current_user,
      parameters: {
        label: @profile_field.label,
        value: @profile_field.value,
        parent_label: @profile_field.parent.try(:label),
        parent_value: @profile_field.parent.try(:value),
        type: @profile_field.type
      }
    )
  end

end
