module BodyHelper

  def body_tag
    content_tag :body,
      class: [
        controller.controller_name,
        "#{current_layout}-layout",
        "#{current_layout}_layout",
        @navable.try(:class).try(:name).try(:parameterize)
      ].join(" "),
      data: {
        locale: I18n.locale,
        env: Rails.env.to_s,
        layout: current_layout,
        navable: @navable.try(:to_global_id)
      } do
      yield
    end
  end

end