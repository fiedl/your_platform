class AttachmentsController < ApplicationController
  
  skip_filter *_process_action_callbacks.map(&:filter), only: :download # skip all filters for downloads
  load_and_authorize_resource
  skip_authorize_resource only: [:create, :description]
  respond_to :html, :json
  layout nil
  
  def index
  end

  def create
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
    @attachment.update_attributes(params[:attachment])
    head :no_content
  end


  # PUT /attachments/1
  # PUT /attachments/1.json
  def update
    @attachment = Attachment.find(params[:id])

    respond_to do |format|
      if @attachment.update_attributes(params[:attachment])
        format.html { redirect_to @attachment, notice: 'Attachment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @attachment = Attachment.find(params[:id])
    @attachment.destroy
  end

  # This action allows to download a file, which is not in the public/ directory
  # but at a secured location. That way, access control for uploaded files cannot
  # be circumvented by downloading files directly from the public folder.
  #
  # https://github.com/carrierwaveuploader/carrierwave/wiki/How-To%3A-Secure-Upload
  #
  def download
    path = ""
    if secure_version
      if @attachment.file.versions[secure_version]
        path = @attachment.file.versions[secure_version].current_path
      end
    else
      current_user.track_visit @attachment.parent if @attachment.parent && current_user
      path = @attachment.file.current_path
    end
    send_file path, x_sendfile: true, disposition: :inline
  end
  
  # This returns a json object with description information of the
  # requested file.
  #
  def description
    @attachment = Attachment.find(params[:attachment_id])
    authorize! :read, @attachment

    respond_to do |format|
      format.json do
        self.formats = [:html, :json]
        render json: {
          title: @attachment.title,
          description: @attachment.description,
          author: @attachment.author.try(:title),
          html: render_to_string(partial: 'attachments/description', formats: [:html], locals: {attachment: @attachment})
        }
      end
    end
  end
  
private

  # This method secures the version parameter from a DoS attack.
  # See: http://brakemanscanner.org/docs/warning_types/denial_of_service/
  #
  def secure_version
    @secure_version ||= AttachmentUploader.valid_versions.select do |version|
      version.to_s == params[:version]
    end.first
  end
  
  def secure_parent
    return Page.find(params[:attachment][:parent_id]) if params[:attachment][:parent_type] == 'Page'
    return Event.find(params[:attachment][:parent_id]) if params[:attachment][:parent_type] == 'Event'
  end

end
