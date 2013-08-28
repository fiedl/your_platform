module ApplicationHelper
  
  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    if block_given?
      yield presenter 
    else
      presenter.present()
    end
  end
  
end
