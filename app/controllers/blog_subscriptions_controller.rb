class BlogSubscriptionsController < ApplicationController

  before_action :create_guest_user_from_form_data, only: [:create]

  expose :blog
  expose :email, -> { params[:email] }

  def create
    authorize! :subscribe_to, blog

    token = Digest::SHA1.hexdigest([Time.now, rand].join)
    Rails.cache.write(["blog_subscriptions", token], {
      user_id: current_user.id,
      blog_id: blog.id
    }, expire_in: 3.days)

    # This sends an email to the user who needs to click a confirmation link
    # in order to conform with the double-opt-in requirement of new
    # privacy laws.
    #
    # The confimation link is handled by the `BlogSubscriptionConfirmationController`.
    #
    confirmation_link = create_blog_subscription_confirmation_url(token: token, host: current_home_page.domain)
    BlogSubscriptionConfirmationMailer.blog_subscription_confirmation_email(current_user, blog.title, confirmation_link).deliver

    redirect_to blog, notice: t(:please_confirm_your_subscription_to_str_via_email_token, str: blog.title)
  end

  def destroy
    authorize! :subscribe_to, blog

    blog.unsubscribe(current_user.email) if current_user
    redirect_to blog, notice: t(:you_have_unsubscribed_str, str: blog.title)
  end

end