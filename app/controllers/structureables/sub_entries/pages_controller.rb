class Structureables::SubEntries::PagesController < Structureables::SubEntriesController

  def create
    authorize! :create_page_for, parent

    new_page = parent.child_pages.create title: t(:new_page), author_user_id: current_user.id, type: secure_child_type
    parent.delete_cached :nav_child_page_ids if Page.use_caching?

    redirect_to parent
  end

  private

  def secure_child_type
    params[:child_type] if params[:child_type].start_with?("Pages::")
  end

end