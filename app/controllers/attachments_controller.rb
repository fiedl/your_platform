class AttachmentsController < ApplicationController

  skip_filter *_process_action_callbacks.map(&:filter), only: :download # skip all filters for downloads
  skip_before_action :verify_authenticity_token, only: [:create] # via inline-attachment gem
  load_and_authorize_resource except: [:index]
  skip_authorize_resource only: [:create, :description]
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
    @attachment.update_attributes(params[:attachment])

    respond_to do |format|
      format.json { render json: Attachment.find(@attachment.id) } # reload does not reload the filename, thus use `find`.
    end
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
        content_type = @attachment.file.versions[secure_version].content_type
      end
    else
      current_user.track_visit @attachment.parent if @attachment.parent && current_user && (not current_user.incognito?)
      path = @attachment.file.current_path
      content_type = @attachment.content_type
    end
    send_file path, x_sendfile: true, disposition: :inline,
      range: (@attachment.video?), type: content_type
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

  def send_file(path, options = {})
    if options[:range]
      send_file_with_range(path, options)
    else
      super(path, options)
    end
  end

  # To stream videos, we have to handle the requested byte range.
  #
  # For a summary, see http://stackoverflow.com/a/37570158/2066546.
  #
  # In order to find out the correct headers, we've put a test-video.mp4 into the public folder
  # and inspected the requests. For example, the first requests results in a 200 to check if the
  # video is actually there. Then, the byte range is requested and the corresponding data is sent.
  #
  # Sending the correct data and extracting the byte range from the request header
  # is taken from http://stackoverflow.com/q/22581727/2066546.
  #
  # Possible alternative, but did not work with Rails 4.2:
  # https://github.com/adamcooke/send_file_with_range
  #
  def send_file_with_range(path, options = {})
    if File.exist?(path)
      size = File.size(path)
      if !request.headers["Range"]
        status_code = 200 # 200 OK
        offset = 0
        length = File.size(path)
      else
        status_code = 206 # 206 Partial Content
        bytes = Rack::Utils.byte_ranges(request.headers, size)[0]
        offset = bytes.begin
        length = bytes.end - bytes.begin
      end
      response.header["Accept-Ranges"] = "bytes"
      response.header["Content-Range"] = "bytes #{bytes.begin}-#{bytes.end}/#{size}" if bytes

      send_data IO.binread(path, length, offset), options
    else
      raise ActionController::MissingFile, "Cannot read file #{path}."
    end
  end

end
