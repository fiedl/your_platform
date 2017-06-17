class Mobile::PhotosController < Mobile::BaseController

  expose :event
  expose :photos, -> { event.try(:image_attachments) || current_user.event_images.last(100) }
  expose :photo, -> { Attachment.find(params[:id]) if params[:id] }

  def index
    authorize! :read, :mobile_photos

    set_current_title "Fotos"
  end

  def create
    raise 'no event given' unless event
    authorize! :create_attachment_for, event
    current_user.join(event)

    params[:files].each do |file|
      event.attachments.create! author: current_user, file: file
    end

    redirect_to :back, notice: "TODO: SHOW ATTACHMENTS"
  end

  def show
    authorize! :read, :mobile_photos
  end

end