class Structureables::SubEntriesController < ApplicationController

  expose :object, -> { find_object }
  expose :parent, -> { find_parent }

  def destroy
    authorize! :update, parent

    link = object.links_as_child.find_by(ancestor_id: parent.id, ancestor_type: parent.class.base_class.name)
    link.destroy!
    if Group.use_caching?
      parent.delete_cached :nav_child_page_ids if object.kind_of?(Page)
      parent.delete_cached :nav_child_group_ids if object.kind_of?(Group)
      parent.delete_cached :member_table_rows if object.kind_of?(Group)
    end
    render json: {}, status: :ok
  end

  private

  def find_parent
    return Group.find params[:parent_id] if params[:parent_type] == 'Group'
    return Page.find params[:parent_id] if params[:parent_type] == 'Page'
    return Event.find params[:parent_id] if params[:parent_type] == 'Event'
    return GlobalID::Locator.locate params[:parent_gid] if params[:parent_gid]
  end

  def find_object
    GlobalID::Locator.locate params[:object_gid] if params[:object_gid]
  end

end