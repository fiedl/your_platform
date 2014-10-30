class OfficersController < ApplicationController
  
  # Required params:
  #   - group_id or page_id
  #   - name
  #
  def create_officers_group
    @structureable = secure_structureable
    authorize! :create_officers_group_for, @structureable
    
    @officers_group = @structureable.officers_parent.child_groups.create name: params[:name]
    
    respond_to do |format|
      format.html { redirect_to @structureable }
      format.json { render json: @officers_group.attributes.merge({
        officers_group_entry_html: render_to_string(partial: 'officers/officers_group_entry', formats: [:html], handlers: [:haml], layout: false, locals: {officer_group: @officers_group})
      })}
    end
  end
  
  private
  
  def secure_structureable
    return Group.find(params[:group_id]) if params[:group_id].present?
    return Page.find(params[:page_id]) if params[:page_id].present?
  end
  
end