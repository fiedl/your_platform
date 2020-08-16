class GroupsController < ApplicationController
  include MarkdownHelper
  before_action :load_resource, only: [:show, :update, :destroy]
  authorize_resource :group, except: [:create, :test_welcome_message]
  respond_to :html, :json, :csv, :ics

  expose :user, -> { User.find params[:user_id] if params[:user_id].present? }
  expose :parent, -> { user }
  expose :groups, -> { parent.groups.regular }

  def index
    raise 'no parent given' unless parent
    authorize! :read, parent

    set_current_navable parent
    set_current_title "Gruppen von #{parent.title}"
    set_current_tab :members
  end

  expose :group
  expose :officer_groups, -> { group.important_officer_groups.any? ? group.important_officer_groups : group.officers_groups_of_self_and_descendant_groups }

  def show
    set_current_title group.title
    set_current_navable group
    set_current_tab :contacts

    # Log exports.
    #
    if not request.format.html?
      PublicActivity::Activity.create!(
        trackable: @group,
        key: "Export #{params[:list] || params[:pdf_type]}",
        owner: current_user,
        parameters: params.to_unsafe_hash.except('authenticity_token')
      )
    end

    respond_to do |format|
      format.html
      format.pdf do
        authorize! :read, @group
        authorize! :export_member_list, @group

        if params[:sender].present?
          # TODO: This should not be inside a GET request; but I wasn't sure how to do it properly.
          session[:address_labels_pdf_sender] = params[:sender]
        end
        options = {sender: params[:sender], book_rate: params[:book_rate], export_user: current_user, filter: params[:filter]}

        if params[:pdf_type].present?
          options[:type] = "AddressLabelsDpag7037Pdf" if params[:pdf_type].include?("dpag")
          options[:type] = "AddressLabelsZweckform3475Pdf" if params[:pdf_type].include?("zweckform")
        else
          options[:type] = "AddressLabelsZweckform3475Pdf"
        end

        file_title = "#{I18n.t(:address_labels)} #{@group.name} #{Time.zone.now}".parameterize

        # Possible dispositions: attachment, inline.
        # Windows users with the Adobe Reader browser plugin can't print with 100% scale from the browser plugin.
        # They would need to download and open the file in Adobe Reader standalone to print at 100% scale.
        # Therefore, we use 'attachment' here in order to prevent the use of the browser plugin.
        #
        send_data(@group.members_to_pdf(options), filename: "#{file_title}.pdf", type: 'application/pdf', disposition: 'inline')
      end
    end
  end

  def update
    @group.update_attributes!(group_params)
    render json: {}, status: :ok
  end

  def create
    if secure_parent_type.present? && params[:parent_id].present?
      @parent = secure_parent_type.constantize.find(params[:parent_id]).child_groups
    else
      @parent = Group
    end

    authorize! :create_group_for, @parent
    @new_group = @parent.create(name: I18n.t(:new_group))

    respond_with @new_group
  end

  def destroy
    @group.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  # POST groups/123/test_welcome_message
  def test_welcome_message
    @group = Group.find params[:group_id]
    authorize! :update, @group
    notification = @group.send_welcome_message_to current_user
    Notification.deliver_for_user current_user
    respond_to do |format|
      format.json { render json: notification }
    end
  end

  private

  def load_resource
    @group = Group.find params[:id]
    point_navigation_to @group
  end

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
    # Need to sync in both directions for best in place:
    params[:corporation] ||= params[:group]
    params[:officer_group] ||= params[:group]

    # STI override:
    params[:group] ||= params[:corporation] # for Corporation objects
    params[:group] ||= params[:officer_group] # for OfficerGroup objects

    params.require(:group).permit(*permitted_group_attributes)
  end

  def permitted_group_attributes
    permitted_keys = []
    permitted_keys += [:name, :extensive_name] if can? :rename, @group
    permitted_keys += [:token] if can? :change_token, @group
    permitted_keys += [:internal_token] if can? :change_internal_token, @group
    permitted_keys += [:direct_members_titles_string] if can? :update_memberships, @group
    permitted_keys += [:body, :welcome_message] if can? :update, @group
    permitted_keys += [:mailing_list_sender_filter] if can? :update, @group
    permitted_keys += [:avatar, :avatar_background] if can? :update, @group
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
    @descendant_groups_map_profile_fields ||= ProfileField.where( type: "ProfileFields::Address", profileable_type: "Group", profileable_id: @group.descendant_group_ids )
  end
  def child_groups_map_profile_fields
    @child_groups_map_profile_fields ||= ProfileField.where( type: "ProfileFields::Address", profileable_type: "Group", profileable_id: @group.child_group_ids )
  end
  def own_map_profile_fields
    @own_map_profile_fields ||= ProfileField.where( type: "ProfileFields::Address", profileable_type: "Group", profileable_id: @group.id )
  end
  def users_map_profile_fields
    @users_map_profile_fields ||= ProfileField.where( type: "ProfileFields::Address", profileable_type: "User", profileable_id: @members.collect { |member| member.id } ).includes(:profileable)
  end


  def secure_parent_type
    params[:parent_type] if params[:parent_type].in? ['Group', 'Page']
  end


  def redirect_to_group_tab
    redirect_to current_tab_path(@group)
  end

end
