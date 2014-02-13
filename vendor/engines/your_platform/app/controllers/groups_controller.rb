class GroupsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource
  
  def index
    point_navigation_to Page.intranet_root
    respond_with @groups
  end

  def index_mine
    point_navigation_to current_user
    @groups = current_user.groups
    respond_with @groups
  end

  def show
    if @group
      point_navigation_to @group
      
      @members = @group.members.order(:last_name, :first_name)
      @members = @members.page(params[:page]).per_page(25) # pagination

      @map_address_fields = map_address_fields

      # @posts = @group.posts.order("sent_at DESC").limit(10)
      
      @new_user_group_membership = @group.build_membership
    end
    respond_with @group
    metric_logger.log_event @group.attributes, type: :show_group
  end

  def update
    @group.update_attributes(group_params)
    respond_with @group
  end

  def create
    if secure_parent_type.present? && params[:parent_id].present?
      @parent = secure_parent_type.constantize.find(params[:parent_id]).child_groups
    else
      @parent = Group
    end
    if can? :manage, @parent
      @new_group = @parent.create(name: I18n.t(:new_group))
    end
    respond_with @new_group
  end
  
  private
  
  # This method returns the request parameters and their values as long as the user
  # is permitted to change them. 
  # 
  # This mechanism protects from mass assignment hacking and replaces the old
  # attr_accessible mechanism. 
  # 
  # For more information, have a look at these resources:
  #   https://github.com/rails/strong_parameters/
  #   http://railscasts.com/episodes/371-strong-parameters
  # 
  def group_params
    if can? :manage, @group
      params.require(:group).permit(:name, :token, :internal_token, :extensive_name)  # TODO: Additionally needed?
    elsif can? :update, @group
      params.require(:group).permit(:name, :token, :internal_token, :extensive_name)
    end
  end  
  
  # This method collects the address fields for displaying the large map
  # on group pages.
  #
  # https://github.com/apneadiving/Google-Maps-for-Rails/wiki/Controller
  #
  def map_address_fields
    if @group.members.count < 260  # arbitrary limit by jbx26. TODO Remove this when obsolete.
      
      user_ids = @group.member_ids
      user_address_fields = ProfileField.where( type: "ProfileFieldTypes::Address", profileable_type: "User", profileable_id: user_ids )
      
      group_ids = [ @group.id ] + @group.descendant_group_ids
      group_address_fields = ProfileField.where( type: "ProfileFieldTypes::Address", profileable_type: "Group", profileable_id: group_ids )
      
      (user_address_fields + group_address_fields)
    else
      []
    end
  end
  
  def secure_parent_type
    params[:parent_type] if params[:parent_type].in? ['Group', 'Page']
  end

end
