class AttachmentsController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:create] # via inline-attachment gem
  load_and_authorize_resource except: [:index]
  skip_authorize_resource only: [:create]
  respond_to :html, :json
  layout nil

  def index
    @parent = Page.find params[:page_id] if params[:page_id]
    @parent = Post.find params[:post_id] if params[:post_id]
    @parent = Event.find params[:post_id] if params[:event_id]
    authorize! :read, @parent

    @attachments = @parent.attachments

    set_current_navable @parent
    set_current_title t(:attachments_of_str, str: @parent.title)
    set_current_access :admin
    set_current_access_text :only_global_admins_can_access_this
  end

  def create
    handle_inline_attachment_uploads
    if secure_parent
      authorize! :create_attachment_for, secure_parent
      secure_parent.touch
      if secure_parent.kind_of?(Event) and can?(:join, secure_parent) and not secure_parent.attendees.include?(current_user)
        # Auto-join the event on upload.
        current_user.join(secure_parent)
      end
    else
      authorize! :create, Attachment
    end

    @attachment = Attachment.create! author: current_user
    @attachment.update_attributes(attachment_params)

    respond_to do |format|
      format.json { render json: Attachment.find(@attachment.id) } # reload does not reload the filename, thus use `find`.
    end
  end


  # PUT /attachments/1
  # PUT /attachments/1.json
  def update
    @attachment = Attachment.find(params[:id])
    authorize! :update, @attachment

    respond_to do |format|
      if @attachment.update_attributes(attachment_params)
        format.html { redirect_to @attachment, notice: 'Attachment was successfully updated.' }
        format.json { respond_with_bip(@attachment) }
      else
        format.html { render action: "edit" }
        format.json { respond_with_bip(@attachment) }
      end
    end
  end

  def destroy
    @attachment = Attachment.find(params[:id])
    @attachment.destroy
  end

private

  def attachment_params
    params.require(:attachment).permit(:description, :file, :parent_id, :parent_type, :title, :author, :author_title, :type)
  end


  def secure_parent
    return Page.find(params[:attachment][:parent_id]) if params[:attachment][:parent_type] == 'Page'
    return Event.find(params[:attachment][:parent_id]) if params[:attachment][:parent_type] == 'Event'
    return SemesterCalendar.find(params[:attachment][:parent_id]) if params[:attachment][:parent_type] == 'SemesterCalendar'
  end

  # When uploading images through the inline-attachment gem,
  # we need to takt the parameters from other variables.
  #
  # https://github.com/Rovak/InlineAttachment
  #
  def handle_inline_attachment_uploads
    if params[:inline_attachment].to_b == true
      params[:attachment] ||= {}
      params[:attachment][:parent_type] ||= params[:parent_type] if params[:parent_type].present?
      params[:attachment][:parent_id] ||= params[:parent_id] if params[:parent_id].present?
      params[:attachment][:file] ||= params[:file] if params[:file] # inline-attachment gem
    end
  end

end
