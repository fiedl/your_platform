module PagesHelper

  def destroy_page_button(page, label = "")
    if can? :destroy, page
      link_to(icon(:trash), page_path(page, format: 'json'), method: 'delete',
        class: 'btn btn-danger destroy_page',
        title: I18n.t(:a_new_page_can_be_destroyed_within_ten_minutes),
        remote: true) +
      label
    end
  end

end