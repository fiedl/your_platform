class GroupMemberDataSummariesController < ApplicationController
  
  def index
    @group = Group.find params[:group_id]
    authorize! :update_members, @group
    
    @members = @group.members
    
    case params[:sort_by]
    when 'name', '', nil
      @members = @members.order(:last_name, :first_name)
    when 'member_since'
      @members = @members.sort_by do |member|
        member.membership_in(@group).valid_from
      end.reverse
    end
    
    set_current_navable @group
    set_current_title "#{t(:data_administration)}: #{@group.title}"
  end
  
end