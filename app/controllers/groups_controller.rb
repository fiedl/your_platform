class GroupsController < ApplicationController
  respond_to :html, :json

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
    render action: 'index'
  end

  def show
    @group = Group.find_by_id params[ :id ]
    if @group
      @navable = @group
      @title = @group.name
      @groups = @group.child_groups
      @users = @group.descendant_users
    end
  end

  def update
    @group = Group.find params[ :id ]
    @group.update_attributes( params[ :group ] )
    respond_with @group
  end

end
