class Structureables::SubEntriesController < ApplicationController

  expose :object, -> { find_object }
  expose :parent, -> { find_parent }

  def destroy
    authorize! :manage, parent

    link = object.links_as_child.find_by(ancestor_id: parent.id, ancestor_type: parent.class.base_class.name)
    link.destroy!
    parent.delete_cached :nav_child_page_ids if Page.use_caching? && object.kind_of?(Page)
    parent.delete_cached :nav_child_group_ids if Group.use_caching? && object.kind_of?(Group)
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