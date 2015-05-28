class OfficersController < ApplicationController
  skip_authorization_check only: :index
    
  def index
    @group = Group.find(params[:group_id]) || raise('no group found')
    @structureable = @group
    authorize! :read, @structureable
    
    @officer_groups = @structureable.descendant_groups.where(type: 'OfficerGroup')
    @officer_groups_by_scope = @officer_groups.group_by { |officer_group| officer_group.scope }
    @officer_groups_by_scope = @officer_groups_by_scope.sort_by { |scope, officer_groups| scope.id }
    
    point_navigation_to @structureable
    @title = "#{@structureable.title}: #{t(:all_officers)}"
    
    cookies[:group_tab] = "officers"
    current_user.try(:update_last_seen_activity, "#{t(:looks_at_officers)}: #{@group.title}", @group)
  end
  
  # Required params:
  #   - group_id or page_id
  #   - name
  #
  def create_officers_group
    @structureable = secure_structureable
    authorize! :create_officers_group_for, @structureable
    
    @officers_group = @structureable.officers_parent.child_groups.create name: params[:name]
    @officers_group.update_attribute :type, 'OfficerGroup'
    
    respond_to do |format|
      format.html { redirect_to @structureable }
      format.json { render json: @officers_group.attributes.merge({
        officers_group_entry_html: render_to_string(partial: 'officers/officers_group_entry', formats: [:html], handlers: [:haml], layout: false, locals: {officer_group: @officers_group, structureable: @structureable})
      })}
    end
  end
  
  private
  
  def secure_structureable
    return Group.find(params[:group_id]) if params[:group_id].present?
    return Page.find(params[:page_id]) if params[:page_id].present?
  end
  
end