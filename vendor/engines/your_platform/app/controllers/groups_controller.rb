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
      
      @child_users = @group.child_users
      @child_users = @child_users.page(params[:page]).per_page(25) # pagination

      user_ids = @group.descendant_users.collect { |user| user.id }
      @map_address_fields = ProfileField.where( type: "ProfileFieldTypes::Address", profileable_type: "User", profileable_id: user_ids )

      @posts = @group.posts.order("sent_at DESC").limit(10)
    end
    respond_with @group
  end

  def update
    @group.update_attributes(group_params)
    respond_with @group
  end

  def create
    if params[:parent_type].present? && params[:parent_id].present?
      @parent = params[:parent_type].constantize.find(params[:parent_id]).child_groups
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
      params.require(:group).permit!  # permit all attributes
    elsif can? :update, @group
      params.require(:group).permit(:name, :token, :internal_token, :extensive_name)
    end
  end  

end
