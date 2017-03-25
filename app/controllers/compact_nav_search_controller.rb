# This controller drives the experimental compact navigtion search bar,
# which is used by the "compact" layout.
#
class CompactNavSearchController < ApplicationController

  before_action :find_object

  def show
    find_object
    authorize! :read, @object

    respond_to do |format|
      format.json do
        if @object
          render json: {
            title: @object.title,
            exact_query: query,
            type: @object.class.name,
            base_type: @object.class.base_class.name,
            id: @object.id,
            url: url_for(@object),
            button_html: render_partial('shared/compact_nav_button', obj: @object)
          }
        else
          render json: {}
        end
      end
      format.html do
        index
      end
    end
  end

  def index
    @query = query
    @base_object = find_base_object
    @results = find_objects.select { |obj| can? :read, obj }
  end

  private

  def query
    params[:query]
  end
  def like_query
    "%#{query}%"
  end

  def find_object
    @object = base.descendant_groups.find_by token: query if base.respond_to? :descendant_groups
    @object ||= NavNode.where('url_component like ?', like_query).limit(1).first.try(:navable) if not params[:search_base].present?  # for example "erlangen/" -- as entry point for navigation
    @object ||= base.descendant_groups.where('name like ?', like_query).limit(1).first if base.respond_to? :descendant_groups
    @object ||= base.descendant_pages.where('title like ?', like_query).limit(1).first if base.respond_to? :descendant_pages
    @object ||= base.descendant_users.where('last_name like ?', like_query).limit(1).first if base.respond_to? :descendant_users
    @object ||= base.descendant_events.where('name like ?', like_query).limit(1).first if base.respond_to? :descendant_events
    return @object
  end

  def find_objects
    @objects = []
    @objects += base.descendant_groups.where('name like ?', like_query) if base.respond_to? :descendant_groups
    @objects += base.descendant_pages.where('title like ?', like_query) if base.respond_to? :descendant_pages
    @objects += base.descendant_users.where('last_name like ?', like_query) if base.respond_to? :descendant_users
    @objects += base.descendant_events.where('name like ?', like_query) if base.respond_to? :descendant_events

    return @objects
  end

  def base
    find_base_object
  end
  def find_base_object
    if params[:search_base].present?
      secure_base_object_class.find(params[:search_base][:id])
    else
      Page.find_root
    end
  end
  def secure_base_object_class
    (%w(Group Corporation Page User Event) & [params[:search_base][:type]]).first.constantize
  end

end