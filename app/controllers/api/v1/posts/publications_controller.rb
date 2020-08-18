class Api::V1::Posts::PublicationsController < Api::V1::BaseController

  expose :post
  expose :parent_groups, -> { Group.where id: params[:parent_group_ids] if params[:parent_group_ids].present? }


  def create
    authorize! :update, post

    post.update! post_params.merge({
      published_at: Time.zone.now
    })

    assign_parent_groups if parent_groups
    deliver_post_as_email if params[:send_via_email].to_b

    render json: post.as_json(include: :attachments).merge({
      author: post.author.as_json.merge({
        path: polymorphic_path(post.author)
      }),
      can_update_publish_on_public_website: can?(:update_public_website_publication, post)
    }), status: :ok
  end

  private

  def post_params
    params.require(:post).permit(:text, :publish_on_public_website)
  end

  def assign_parent_groups
    parent_groups.each { |group| authorize! :create_post, group }
    post.parent_groups = parent_groups
  end

  def deliver_post_as_email
    post.parent_groups.each { |group| authorize! :create_post_via_email, group }

    recipients = ([current_user] + post.parent_groups.collect { |group| group.members }.flatten).uniq
    recipients.each do |recipient_user|
      PostDelivery.where(post_id: post.id, user_id: recipient_user.id).first_or_create
      post.update! sent_at: Time.zone.now
      DeliverPostViaEmailJob.perform_later post_id: post.id, recipient_user_id: recipient_user.id
    end
  end

end