class AttachmentsController < ApplicationController
  
  load_and_authorize_resource
  skip_authorize_resource only: [:create]
  
  def index
  end

  def create
    if secure_parent
      authorize! :create_attachment_for, secure_parent
    else
      authorize! :create, Attachment
    end
    @attachment = Attachment.create! author: current_user
    @attachment.update_attributes(params[:attachment])
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
      path = @attachment.file.current_path
    end
    send_file path, x_sendfile: true, disposition: :inline
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
    Page.find(params[:attachment][:parent_id]) if params[:attachment][:parent_type] == 'Page'
  end

end
