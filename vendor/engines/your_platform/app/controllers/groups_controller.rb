class GroupsController < ApplicationController
  respond_to :html, :json, :csv
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
      current_user.try(:update_last_seen_activity, "sieht sich Mitgliederlisten an: #{@group.title}", @group)

      if request.format.html?
        point_navigation_to @group
        
        # If this is a collection group, e.g. the corporations_parent group, 
        # do not list the single members.
        #
        if @group.group_of_groups?
          @memberships = []
          @child_groups = @group.child_groups - [@group.find_officers_parent_group]
        else
          
          # For corporation groups, there has been some confusion, which members
          # are shown in the list. Thus, modify the list to match the users' 
          # expectations.
          #
          if @group.corporation?
            @corporation = @group.becomes(Corporation)
            if @corporation.respond_to?(:aktivitas) and @corporation.aktivitas and @corporation.philisterschaft 
              # FIXME This is a Wingolf-specific hack! For, example, this could be moved into `@corporation.corporation_members` vs. `@corporation.members`.
              aktivitas_and_philisterschaft_member_ids = @corporation.aktivitas.member_ids + @corporation.philisterschaft.member_ids
              @memberships = @corporation.memberships.where(descendant_id: aktivitas_and_philisterschaft_member_ids).includes(:descendant)
            else
              @memberships = @corporation.memberships.includes(:descendant) - @corporation.former_members_memberships - @corporation.deceased_members_memberships
            end
          else
            
            # This is the standard case:
            #
            @memberships = @group.memberships.includes(:descendant).order(valid_from: :desc)
          end
        end
        
        # Make sure only members that are allowed to be seen are in this array!
        #
        @memberships.select! { |membership| can?(:read, membership.user) }
        
        # Fill also the members into a separate variable.
        #
        @members = @memberships.collect { |membership| membership.user }
        
        # for performance reasons deactivated for the moment.
        # fill_map_address_fields
        @large_map_address_fields = []
        
        # @posts = @group.posts.order("sent_at DESC").limit(10)
        
        @new_user_group_membership = @group.build_membership
      end
    end
    
    respond_to do |format|
      format.html
      format.csv do
        authorize! :export_member_list, @group  # Require special authorization!
        file_title = "#{@group.name} #{params[:list]} #{Time.zone.now}".parameterize
        # See: http://railscasts.com/episodes/362-exporting-csv-and-excel
        bom = "\377\376".force_encoding('utf-16le')
        csv_data = bom + @group.members_to_csv(params[:list]).encode('utf-16le')
        send_data csv_data, filename: "#{file_title}.csv"
      end
      format.pdf do
        authorize! :export_member_list, @group  # Require special authorization!
        if params[:sender].present?
          # TODO: This should not be inside a GET request; but I wasn't sure how to do it properly.
          session[:address_labels_pdf_sender] = params[:sender]
        end
        options = {sender: params[:sender]}
        file_title = "#{I18n.t(:address_labels)} #{@group.name} #{Time.zone.now}".parameterize
        send_data(@group.members_to_pdf(options), filename: "#{file_title}.pdf", type: 'application/pdf', disposition: 'inline')
      end
    end
    
    metric_logger.log_event @group.try(:attributes), type: :show_group
  end

  def update
    @group.update_attributes(group_params)
    respond_with @group
  end

  def create
    if secure_parent_type.present? && params[:parent_id].present?
      @parent = secure_parent_type.constantize.find(params[:parent_id]).child_groups
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
      params.require(:group).permit(:name, :token, :internal_token, :extensive_name, :direct_members_titles_string)  # TODO: Additionally needed?
    elsif can? :update, @group
      params.require(:group).permit(:name, :token, :internal_token, :extensive_name)
    end
  end
  
  def fill_map_address_fields
    fill_small_map_address_fields
    fill_large_map_address_fields
  end
  
  def fill_small_map_address_fields
    # On collection groups, e.g. the corporations_parent group, only the
    # groups should be shown on the map. These groups have a lot of
    # child groups with address profile fields.
    #
    if child_groups_map_profile_fields.count > 0
      @users_map_profile_fields = []
      @groups_map_profile_fields = child_groups_map_profile_fields
    elsif child_groups_map_profile_fields.count == 0
      
      # To prevent long loading times, users map profile fields should only
      # be loaded when there are not too many.
      #
      # TODO: Remove this when the map addresses are cached.
      # TODO: Cache map address fields.
      #
      if @group.member_ids.count < 100  # arbitrary limit.
        @users_map_profile_fields = users_map_profile_fields
      else
        @users_map_profile_fields = []
      end
      
      # Only if there are descendant group address fields, fill the variable
      # for the large map. If there is only the own address, the view
      # will render a small map instead of the large one.
      #
      if descendant_groups_map_profile_fields.count > 0
        @groups_map_profile_fields = own_map_profile_fields + descendant_groups_map_profile_fields
      else
        @groups_map_profile_fields = []
      end
    end
  end
  
  def fill_large_map_address_fields
    # TODO: Make this more efficient.
    # This can be done by using @user_map_profile_fields and @group_map_profile_fields
    # separately when creating the map, because then, there is no need to check the
    # type of the profileable. 
    # But, this makes no sense at the moment, since the profileable objects have
    # to be loaded anyway, since we need the title of the profileables.
    #
    @large_map_address_fields = @users_map_profile_fields + @groups_map_profile_fields
  end
  
  
  # These methods collect the address fields for displaying the large map
  # on group pages.
  #
  # https://github.com/apneadiving/Google-Maps-for-Rails/wiki/Controller
  #
  def descendant_groups_map_profile_fields
    @descendant_groups_map_profile_fields ||= ProfileField.where( type: "ProfileFieldTypes::Address", profileable_type: "Group", profileable_id: @group.descendant_group_ids )
  end
  def child_groups_map_profile_fields
    @child_groups_map_profile_fields ||= ProfileField.where( type: "ProfileFieldTypes::Address", profileable_type: "Group", profileable_id: @group.child_group_ids )
  end
  def own_map_profile_fields
    @own_map_profile_fields ||= ProfileField.where( type: "ProfileFieldTypes::Address", profileable_type: "Group", profileable_id: @group.id )
  end
  def users_map_profile_fields
    @users_map_profile_fields ||= ProfileField.where( type: "ProfileFieldTypes::Address", profileable_type: "User", profileable_id: @members.collect { |member| member.id } ).includes(:profileable)
  end
    
  
  def secure_parent_type
    params[:parent_type] if params[:parent_type].in? ['Group', 'Page']
  end

end
