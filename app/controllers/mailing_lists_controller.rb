class MailingListsController < ApplicationController
  skip_authorize_resource :only => :index
  
  def index
    @group = Group.find params[:group_id]
    authorize! :manage, @group
    
    @email_address_fields = @group.profile_fields.where(type: 'ProfileFieldTypes::Email')
    
    point_navigation_to @group
    @title = "#{t(:manage_mailing_lists)}: #{@group.name}"
  end
  
end