concern :CurrentTitle do
  
  included do
    helper_method :current_title
  end
  
  def current_title
    # yield(:title) uses the new mechanism.
    # @title uses the old mechanism.
    # TODO: Remove @title when it is not used in the controllers anymore.
    #
    # See also: TitleHelper
    #
    @title || view_context.content_for(:title)
  end
  
  def set_current_title(title)
    @title = title
  end
  
end