class Api::V1::AttachmentsController < Api::V1::BaseController

  expose :post, -> { Post.find params[:post_id] if params[:post_id] }
  expose :parent, -> { post }

  def create
    authorize! :update, parent

    new_attachment = parent.attachments.create! author: current_user
    new_attachment.update_attributes! attachment_params
    new_attachment.update title: new_attachment.filename.gsub("_", " ").gsub(/\.[a-zA-Z]{3,4}$/, "") unless attachment_params[:title].present?

    render json: attachment_json(Attachment.find(new_attachment.id)), status: :ok  # reload does not reload the filename, thus use `find`
  end

  expose :attachment

  def update
    authorize! :update, attachment
    attachment.update! attachment_params

    render json: attachment_json(attachment), status: :ok
  end

  def destroy
    authorize! :destroy, attachment
    attachment.destroy!

    render json: {}, status: :ok
  end

  private

  def attachment_params
    params.require(:attachment).permit(:file, :title, :description, :author_user_id)
  end

  def attachment_json(attachment)
    attachment.as_json.merge({
      author: attachment.author.as_json.merge({
        title: attachment.author.title
      })
    })
  end

end