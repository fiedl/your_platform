class AttachmentDownloadsController < ActionController::Base
  include CurrentUser
  layout false

  expose :attachment
  expose :version, -> {
    # This method secures the version parameter from a DoS attack.
    # See: http://brakemanscanner.org/docs/warning_types/denial_of_service/
    AttachmentUploader.valid_versions.detect { |v| v.to_s == params[:version] }
  }
  expose :file_path, -> {
    if version
      attachment.file.versions[version].current_path
    else
      attachment.file.current_path
    end
  }
  expose :content_type, -> {
    if version
      attachment.file.versions[version].content_type
    else
      attachment.content_type
    end
  }

  # GET "/attachments/:id(/:version)/*basename.:extension"
  #
  # This action allows to download a file, which is not in the public/ directory
  # but at a secured location. That way, access control for uploaded files cannot
  # be circumvented by downloading files directly from the public folder.
  #
  # https://github.com/carrierwaveuploader/carrierwave/wiki/How-To%3A-Secure-Upload
  #
  def show
    # Thumbnails should be authorized quicky to avoid delay.
    if version == 'thumb'
      authorize! :download_thumb, attachment
    else
      authorize! :download, attachment
    end

    # I'm not sure why this has to be set manually. Just passing the `type`
    # to `send_file` stopped working with rails 5.
    #
    # TODO: Re-check when updating to rails 5.1.
    # In order to test, just open a pdf attachment in development
    # after commenting out this line:
    #
    response.headers["Content-Type"] = content_type

    send_file file_path, x_sendfile: true, disposition: 'inline',
        range: (attachment.video?), type: content_type
  end


  private

  # Only log the request if it's a regular file, no thumbnail.
  #
  def log_request
    super unless params[:version].in? %w(thumb medium)
  end

  # Do not log the download as an administrative activity.
  #
  def log_activity
  end

  # We need to modify `send_file` to allow streaming.
  #
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