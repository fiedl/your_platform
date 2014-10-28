class PostsController < ApplicationController
  
  authorize_resource
  skip_authorize_resource only: [:new, :create]
  
  def index
    @group = Group.find(params[:group_id]) if params[:group_id].present?
    @posts = @group.posts.order('sent_at DESC') if @group
    @title = t :current_posts
    @navable = @group
  end

  def show
    @post = Post.find(params[:id])
    @title = @post.subject
    @navable = @post.group
  end
  
  def new
    @group = Group.find params[:group_id] if params[:group_id].present?
    authorize! :create_post_for, @group
    @navable = @group
  end
  
  def create
    raise 'no group given' unless params[:group_id].present?
    @group = Group.find params[:group_id]
    authorize! :create_post_for, @group

    @text = params[:text]
    @subject = params[:subject]
    
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
    
    for recipient in @recipients
      PostMailer.post_email(@text, [recipient], @subject, current_user).deliver if recipient.email.present?
    end
    
    if params[:recipient] != 'me'
      Post.create! subject: @subject, text: @text, group_id: @group.id, author_user_id: current_user.id, sent_at: Time.zone.now
    end
    
    respond_to do |format|
      format.html do
        flash[:notice] = "Nachricht wurde an #{@recipients.count} Empfänger versandt."
        redirect_to group_url(@group)
      end
      format.json { render json: {recipients_count: @recipients.count} }
    end
    
  end
end
