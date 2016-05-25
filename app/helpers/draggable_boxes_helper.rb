module DraggableBoxesHelper

  def draggable_boxes_row(page)
    if can? :update, page
      content_tag(:div, class: 'row row-eq-height draggable_boxes box_configuration', data: {box_configuration: page.box_configuration.to_json, page_url: page.url}) do
        yield
      end
    else
      content_tag :div, class: 'row row-eq-height box_configuration', data: {box_configuration: page.box_configuration.to_json} do
        yield
      end
    end
  end

end