module PagesHelper

  # The pages to show in the current navable context.
  #
  def current_pages
    if current_navable && current_navable.child_pages.any?
      current_navable.child_pages
    else
      current_user.new_pages
    end
  end

  def destroy_page_button(page, label = "")
    if can? :destroy, page
      link_to(icon(:trash), page_path(page, format: 'json'), method: 'delete',
        class: 'btn btn-danger destroy_page',
        title: I18n.t(:a_new_page_can_be_destroyed_within_ten_minutes),
        remote: true) +
      label
    end
  end

  def publish_page_button(page)
    if page.unpublished? && can?(:publish, page)
      link_to publish_icon, page_publications_path(page_id: page.id), method: :post, remote: true, class: 'btn btn-primary publish_page tool', title: t(:publish_page_which_is_draft_now)
    end
  end

  def visible_pages_only(pages)
    pages = Page.where(id: pages.map(&:id)) if pages.kind_of? Array
    pages.visible_to(current_user, preview_as: params[:preview_as])
  end

end