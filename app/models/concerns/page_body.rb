concern :PageBody do

  def body
    self.content
  end

  def body_html
    MarkdownHelper
    ActionController::Base.helpers.markdown(body)
  end

end