concern :ErrorHandling do

  included do
    # http://railscasts.com/episodes/53-handling-exceptions-revised
    rescue_from "Exception", with: :render_error
    rescue_from CanCan::AccessDenied, with: :render_unauthorized
  end

  def render_error(exception)
    ExceptionNotifier.notify_exception(exception)
    @error_message = exception.message
    if request.format.html?
      render template: "errors/_error"
    else
      raise exception
    end
  end

  def render_unauthorized(exception)
    Rails.logger.info "Access denied for user #{current_user.try(:id)} on #{exception.action} for #{session['exception.subject']}."
    if request.format.html? || controller_name == "attachment_downloads"
      if exception.action || exception.subject
        if exception.subject.kind_of? String or exception.subject.kind_of? Symbol
          subject = exception.subject
        elsif exception.subject.kind_of? ApplicationRecord
          subject = "#{exception.subject.class.name} #{exception.subject.id}"
        elsif exception.subject.respond_to? :name
          subject = exception.subject.name
        else
          subject = ""
        end
        @error_message = "can :#{exception.action}, #{subject}"
      end
      session['return_to_after_login'] = request.fullpath
      render template: "errors/_unauthorized"
      store_location_for :user_account, request.fullpath
    else
      raise CanCan::AccessDenied, exception
    end
  end

end