class MembershipsController < ApplicationController

  authorize_resource

  expose :user, -> { User.find params[:user_id] if params[:user_id] }
  expose :group, -> { Group.find params[:group_id] if params[:group_id] }
  expose :scope, -> { group || user }
  expose :membership, -> {
    DagLink.find(params[:id]) || Membership.find_by_user_and_group(user, group).with_past
  }
  expose :memberships, -> {
    # TODO: Simplify this when the graph database is better integrated.
    if scope.kind_of?(Group)
      scope.descendant_memberships.with_past
    else
      scope.memberships.direct.with_past
    end
  }

  respond_to :json, :html

  def index
    if user
      authorize! :manage, user
      @object = user
    elsif group
      authorize! :index_memberships, group
      @object = group
    else
      raise ActionController::ParameterMissing, 'neither group nor user are given'
    end

    set_current_navable @object
    set_current_title "#{t(:memberships)}: #{@object.title}"
    set_current_activity :is_managing_member_lists, @object
  end

  def show
  end

  def update
    membership.update! membership_params

    render json: membership, status: :ok
  end

  def destroy
    if membership
      membership.destroy
      head :no_content
    end
  end

  private

  def membership_params
    params[:membership] ||= params[:memberships_status]
    params.require(:membership).permit(*permitted_fields)
  end

  def unrestricted_fields
    [:valid_to, :valid_from, :user_title, :user_id, :group_id, :id,
    :valid_from_localized_date, :valid_to_localized_date]
  end

  def permitted_fields
    if can? :manage, membership
      unrestricted_fields + [:needs_review, :ancestor_id, :ancestor_type, :descendant_id, :descendant_type]
    elsif can? :update, membership
      unrestricted_fields
    end
  end


end
