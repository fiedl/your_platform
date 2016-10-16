class TagsController < ApplicationController
  before_action :find_resource
  authorize_resource class: 'ActsAsTaggableOn::Tag'

  def show
    find_taggables
    set_current_title @tag.title
  end

  def update
    @tag.update tag_params
    respond_with_bip @tag
  end

  def edit
    find_taggables
    set_current_title "#{t(:edit_tag)}: #{@tag.name}"
  end

  private

  def tag_params
    params.require(:acts_as_taggable_on_tag).permit(:title, :subtitle, :body)
  end

  def find_resource
    if params[:id]
      @tag = ActsAsTaggableOn::Tag.find params[:id]
    elsif params[:tag_name].to_i > 0
      @tag = ActsAsTaggableOn::Tag.find params[:tag_name]
    elsif params[:tag_name]
      @tag = ActsAsTaggableOn::Tag.find_by name: params[:tag_name]
    else
      @tag = ActsAsTaggableOn::Tag.all
    end
  end

  def find_taggables
    @pages = Page.tagged_with @tag.name
    @taggables = @pages
  end


end