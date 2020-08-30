class GroupMailingListsController < ApplicationController

  expose :group, -> { Group.find params[:group_id] if params[:group_id].present? }
  expose :mailing_lists, -> { group.mailing_lists }

  def index
    authorize! :manage_mailing_lists_for, group

    set_current_navable group
    set_current_title "#{t(:mailing_lists)} #{group.name}"
    set_current_tab :communication
  end

end