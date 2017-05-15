class GroupMailingListsController < ApplicationController
  skip_authorize_resource :only => :index

  def index
    @group = Group.find params[:group_id]
    authorize! :manage_mailing_lists_for, @group

    @email_address_fields = @group.profile_fields.where(type: 'ProfileFields::MailingListEmail')

    set_current_navable @group
    set_current_title "#{t(:manage_mailing_lists)}: #{@group.name}"
  end

end