class PostsController < ApplicationController
  
  authorize_resource
  skip_authorize_resource only: [:new, :create, :preview]
  skip_authorization_check only: [:preview]
  
  # This will skip the cross-site-forgery protection for POST /posts.json,
  # since incoming emails are not sent via a form in this web app,
  # nor is the incoming email signed in.
  #
  # This is copied from:
  # https://github.com/ivaldi/brimir: tickets_controller.rb
  #
  # TODO: Is there a better way to do this?
  #
  skip_before_action :verify_authenticity_token, only: :create, if: 'request.format.json?'
  
  def index
    @group = Group.find(params[:group_id]) if params[:group_id].present?
    @posts = @group.posts.order('sent_at DESC') if @group

    authorize! :index_posts, @group

    @new_post = Post.new
    @new_post.group = @group
    @new_post.author = current_user
    
    set_current_title "#{t(:posts)} - #{@group.name}"
    set_current_navable @group
    set_current_activity :looks_at_posts, @group
    set_current_access :group
    set_current_access_text I18n.t(:all_members_of_group_name_can_read_these_posts, group_name: @group.name)
        
    cookies[:group_tab] = "posts"
  end

  def show
    @post = Post.find(params[:id])
    @group = @post.group
    
    @show_all_comments = true
    
    set_current_title @post.subject
    set_current_navable @group
    set_current_activity :looks_at_posts, @group
    set_current_access :group
    set_current_access_text I18n.t(:members_of_group_name_and_mentioned_users_can_read_and_comment_this_post, group_name: @group.name)
  end
  
  def new
    @group = Group.find params[:group_id] if params[:group_id].present?
    authorize! :create_post_for, @group
    
    @new_post = Post.new
    @new_post.group = @group
    @new_post.author = current_user
        
    set_current_navable @group
    set_current_activity :writes_a_message_to_group, @group
    set_current_access :group
    set_current_access_text I18n.t(:members_of_group_and_global_officers_can_write_posts, group_name: @group.name)
  end
  
  def create
    return create_via_email if params[:message].present?
    
    @group = Group.find(params[:group_id] || params[:post][:group_id] || raise('no group given'))
    authorize! :create_post_for, @group

    @text = params[:text] || params[:post][:text]
    @subject = params[:subject] || params[:post][:text].split("\n").first
    @attachments_attributes = params[:attachments_attributes] || params[:post].try(:[], :attachments_attributes) || []
    
    if params[:recipient] == 'me'
      @recipients = [current_user]
    else
      if params[:valid_from].present?
        @memberships = @group.memberships.started_after(params[:valid_from].to_datetime)
        @recipients = @group.members.where(dag_links: {id: @memberships.map(&:id)})
        raise 'validation error: the number of recipients does not match.' if @recipients.count != params[:recipients_count].to_i
      else
        @recipients = @group.members
      end
    end
    
    @post = Post.new subject: @subject, text: @text, group_id: @group.id, author_user_id: current_user.id, sent_at: Time.zone.now, attachments_attributes: @attachments_attributes
    @post.save! unless params[:recipient] == 'me'
  
    if params[:notification] == "instantly"
      @send_counter = @post.send_as_email_to_recipients @recipients
      Notification.create_from_post(@post, sent_at: Time.zone.now)
      flash[:notice] = "Nachricht wurde an #{@send_counter} Empfänger versandt."
    else
      Notification.create_from_post(@post)
      flash[:notice] = "Nachricht wurde gespeichert. #{@recipients.count} Empfänger werden gemäß ihrer eigenen Benachrichtigungs-Einstellungen informiert, spätestens jedoch nach einem Tag."
    end
    
    Mention.create_multiple_and_notify_instantly(current_user, @post, @post.text)
    
    respond_to do |format|
      format.html do
        redirect_to group_posts_path(@group), change: 'posts'
      end
      format.json { render json: {recipients_count: @send_counter} }
    end
    
  end
  
  def preview
    respond_to do |format|
      format.json do
        render json: {
          text: params[:text],
          preview: view_context.markup(params[:text])
        }
      end
      format.html do
        render html: view_context.markup(params[:text])
      end
    end
  end
  
  private
  
  # This methods processes incoming email messages that can be sent through
  #
  #     POST /posts.json
  #
  # with the message sent as the `message` parameter.
  # This can be tested like this:
  #
  #     cat testmessage.txt | curl -s -o /dev/null --data-urlencode message@- http://127.0.0.1:3000/posts.json
  #
  # We've adopted this idea from:
  # https://github.com/ivaldi/brimir
  #
  def create_via_email
    authorize! :create, :post_via_email
    if params[:message]
      @posts = ReceivedPostMail.new(params[:message]).store_as_posts
      @posts.each { |post| post.send_as_email_to_recipients }
    end
    render json: (@posts || [])
  end
  
end
