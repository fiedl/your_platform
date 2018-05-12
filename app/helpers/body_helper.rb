module BodyHelper

  def body_tag(options = {}, &block)
    css_classes = [
      controller.controller_name,
      "#{current_layout}-layout",
      "#{current_layout}_layout",
      @navable.try(:class).try(:name).try(:parameterize),
      ("public-website" if @navable.kind_of?(Page) && @navable.public?),
      ("demo_mode" if demo_mode?),
      ("ios" if params[:app] == "ios"),
      ("fast-lane" if params[:fast_lane]),
      ("no-fast-lane" if params[:no_fast_lane]),
      options[:class]
    ]
    data = {
      locale: I18n.locale,
      env: Rails.env.to_s,
      layout: current_layout,
      navable: @navable.try(:to_global_id).try(:to_s),
      tab: current_tab
    }
    data[:turbolinks] = options[:turbolinks]
    content_tag :body, class: css_classes.join(" "), data: data do
      yield
    end
  end

end