class Structureables::SubEntriesController < ApplicationController

  expose :parent, -> { find_parent }

  private

  def find_parent
    return Group.find params[:parent_id] if params[:parent_type] == 'Group'
    return Page.find params[:parent_id] if params[:parent_type] == 'Page'
    return Event.find params[:parent_id] if params[:parent_type] == 'Event'
    return GlobalID::Locator.locate params[:parent_gid] if params[:parent_gid]
  end

end