module SlidesHelper
  def current_slides
    slides = Attachments::Slide.all
    parent_page_ids = [current_home_page.id] + current_home_page.descendant_pages.pluck(:id) if current_home_page
    slides = slides.where(parent_type: 'Page', parent_id: parent_page_ids) if parent_page_ids
    slides = Attachments::Slide.all if slides.none?
    return slides
  end
end