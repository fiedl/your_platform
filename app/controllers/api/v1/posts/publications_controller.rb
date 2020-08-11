class Api::V1::Posts::PublicationsController < Api::V1::BaseController

  expose :post

  def create
    authorize! :update, post

    post.update! post_params.merge({published_at: Time.zone.now})
    render json: post, status: :ok
  end

  private

  def post_params
    params.require(:post).permit(:text)
  end

end