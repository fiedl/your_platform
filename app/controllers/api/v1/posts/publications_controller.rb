class Api::V1::Posts::PublicationsController < Api::V1::BaseController

  expose :post

  def create
    authorize! :update, post

    post.update! post_params.merge({published_at: Time.zone.now})
    render json: post.as_json.merge({
      author: post.author.as_json.merge({
        path: polymorphic_path(post.author)
      })
    }), status: :ok
  end

  private

  def post_params
    params.require(:post).permit(:text)
  end

end