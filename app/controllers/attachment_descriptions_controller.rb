class AttachmentDescriptionsController < ApplicationController
  expose :attachment

  # This returns a json object with description information of the
  # requested file.
  #
  def show
    authorize! :read, attachment

    json_data = {
      title: attachment.title,
      description: attachment.description,
      author: attachment.author.try(:title),
      html: render_to_string(partial: 'attachments/description', formats: [:html], locals: {attachment: attachment})
    }

    respond_to do |format|
      format.json do
        self.formats = [:html, :json]
        render json: json_data
      end
    end
  end

end