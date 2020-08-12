class Api::V1::Posts::PublicationsController < Api::V1::BaseController

  expose :post

  def create
    authorize! :update, post

    post.update! post_params.merge({
      published_at: Time.zone.now
    })
    render json: post.as_json(include: :attachments).merge({
      author: post.author.as_json.merge({
        path: polymorphic_path(post.author)
      })
    }), status: :ok
  end

  private

  def post_params
    params.require(:post).permit(:text, :publish_on_public_website)
  end

end