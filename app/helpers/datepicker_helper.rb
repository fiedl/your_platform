module DatepickerHelper

  def datepicker_tag
    content_tag :div, id: "vue-datepicker-app", class: "vue-app" do
      content_tag :datepicker, "", ":language" => "de", ":monday-first" => true, "format" => "dd.MM.yyyy", "value" => Date.today
    end
  end

end