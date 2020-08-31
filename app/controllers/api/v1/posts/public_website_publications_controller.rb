class Api::V1::Posts::PublicWebsitePublicationsController < Api::V1::BaseController

  expose :post

  # PUT /api/v1/posts/:id/public_website_publications
  #
  # This is the endpoint to toggle whether a post should
  # be visible on the public website. This can be changed
  # even after publishing the post.
  #
  def update
    authorize! :update_public_website_publication, post

    post.update! post_params

    render json: post.as_json, status: :ok
  end

  private

  def post_params
    params.require(:post).permit(:publish_on_public_website)
  end

end