module BodyHelper

  def body_tag(options = {})
    content_tag :body,
      class: [
        controller.controller_name,
        "#{current_layout}-layout",
        "#{current_layout}_layout",
        @navable.try(:class).try(:name).try(:parameterize),
        ("demo_mode" if demo_mode?),
        options[:class]
      ].join(" "),
      data: {
        locale: I18n.locale,
        env: Rails.env.to_s,
        layout: current_layout,
        navable: @navable.try(:to_global_id).try(:to_s),
        tab: current_tab
      } do
      yield
    end
  end

end