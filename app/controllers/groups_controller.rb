class GroupsController < ApplicationController
  respond_to :html, :json

  load_and_authorize_resource

  def index
    @user = User.find_by_alias params[ :alias ] if params[ :alias ]
    @title = params[ :title ] if params[ :title ]
    if @user
      @groups = Groups.of_user @user
      @title = "Gruppen von " + @user.name unless @title
    else
      @groups = Groups.all
      @title = "Alle Gruppen" unless @title
    end
  end

  def my
    @title = "Meine Gruppen"
    @user = @session.current_user
    @groups = @user.groups
#    @navables = [ Page.find_root ]
    @navable = @user

    respond_to do |format|
      format.html { render action: 'index' }
      format.json { render json: @groups }
    end
  end

  def show
    if @group
      @navable = @group
      @title = @group.name

      @child_groups = @group.child_groups
      @descendant_users = @group.descendant_users
      @child_users = @group.child_users
      @child_users = @child_users.page(params[:page]).per_page(25) # pagination

      user_ids = @group.descendant_users.collect { |user| user.id }
      @map_address_fields = ProfileField.where( type: "ProfileFieldTypes::Address", profileable_type: "User", profileable_id: user_ids )

      # current posts
      @posts = @group.posts.order("sent_at DESC").limit(10)
    end
  end

  def update
    @group.update_attributes( params[ :group ] )
    respond_with @group
  end

  def create
    if params[:parent_type].present? && params[:parent_id].present?
      @parent = params[:parent_type].constantize.find(params[:parent_id]).child_groups
    else
      @parent = Group
    end
    @new_group = @parent.create( name: I18n.t(:new_group) )
    redirect_to @new_group
  end

end
