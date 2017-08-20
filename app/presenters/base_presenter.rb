# Presenters:
#  * http://railscasts.com/episodes/287-presenters-from-scratch
#  * https://github.com/railscasts/287-presenters-from-scratch
#
# Example:
#   class FooPresenter < BasePresenter
#     presents :foo
#     def present
#       "html code"
#     end
#     def some_generated_code
#        "some generated code"
#     end
#   end
#
#   present @foo do |foo_presenter|
#     foo_presenter.some_generated_code
#   end            # => "some generated code"
#
#   # or:
#   present @foo   # => "html code"
#
class BasePresenter
  def initialize(object, template)
    @object = object
    @template = template
  end

  def present
    raise RuntimeError, "Please override the #present method to return the presenter's html code or use a block. For more information, see BasePresenter."
  end

private

  def self.presents(name)
    define_method(name) do
      @object
    end
  end

  def h
    @template
  end

  def markdown(text)
    Redcarpet.new(text, :hard_wrap, :filter_html, :autolink).to_html.html_safe
  end

  def method_missing(*args, &block)
    @template.send(*args, &block)
  end
end
