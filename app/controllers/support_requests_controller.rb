class SupportRequestsController < ApplicationController
  skip_authorization_check only: :create

  expose :support_group, -> { Group.support }

  expose :support_requests, -> {
    if current_user.groups.include? support_group
      SupportRequest.published.order(updated_at: :desc)
    else
      current_user.support_requests.published.order(updated_at: :desc)
    end
  }

  expose :drafted_post, -> {
    current_user.drafted_posts.where(sent_via: post_draft_via_key).order(created_at: :desc).first_or_create do |post|
      post.parent_groups << support_group
    end
  }

  expose :post_draft_via_key, -> {
    "support-requests"
  }


  def index
    authorize! :index, SupportRequest
  end

  def create
    authorize! :create, :support_request

    @sender_user = current_user
    @to_email = SupportRequestsController.support_email
    @navable = GlobalID::Locator.locate(params[:navable]) if params[:navable].present?
    @text = params[:text]
    @meta_data = {
      sent_over: 'Help-Button',
      browser: params[:browser],
      os: params[:os],
      viewport: params[:viewport],
      locale: I18n.locale,
      location: params[:location],
      displayed_navable_object: @navable.inspect,
      role: (current_user ? Role.of(current_user).for(@navable).to_s : nil)
    }

    SupportRequestMailer.support_request_email(@sender_user, @to_email, @text, @meta_data, @navable).deliver_now

    head :no_content
  end

  def self.support_email
    BaseMailer.default[:from]
  end

end