class Api::V1::Posts::DeliveriesController < Api::V1::BaseController

  expose :post

  def create
    raise "Dieser Post wurde bereits per E-Mail versandt." if post.sent_at.present?
    post.parent_groups.each { |group| authorize!(:deliver_post, group) }

    deliver_post_as_email
    render json: post, status: :ok
  end

  private

  def deliver_post_as_email
    post.update! sent_at: Time.zone.now

    recipients = ([current_user] + post.parent_groups.collect { |group| group.members }.flatten).uniq
    recipients.each do |recipient_user|
      PostDelivery.where(post_id: post.id, user_id: recipient_user.id).first_or_create
      DeliverPostViaEmailJob.perform_later post_id: post.id, recipient_user_id: recipient_user.id
    end
  end

end