class AttachmentDescriptionsController < ApplicationController
  expose :attachment
  expose :only_title?, -> { params[:only_title] }

  # This returns a json object with description information of the
  # requested file.
  #
  def show
    authorize! :read, attachment

    json_data = if only_title?
      {
        title: attachment.title,
        html: render_to_string(partial: 'attachments/description', formats: [:html], locals: {attachment: attachment, only_title: true})
      }
    else
      {
        title: attachment.title,
        description: attachment.description,
        author: attachment.author.try(:title),
        html: render_to_string(partial: 'attachments/description', formats: [:html], locals: {attachment: attachment})
      }
    end

    respond_to do |format|
      format.json do
        self.formats = [:html, :json]
        render json: json_data
      end
    end
  end

  private

  # Do not log loading the description.
  #
  def log_request
  end

  def log_activity
  end

end