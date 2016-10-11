class TagsController < ApplicationController
  before_action :find_resource
  authorize_resource class: 'ActsAsTaggableOn::Tag'

  def show
    @pages = Page.tagged_with @tag.name
    @taggables = @pages

    set_current_title @tag.title
  end

  def update
    @tag.update tag_params
    respond_with_bip @tag
  end

  private

  def tag_params
    params.require(:acts_as_taggable_on_tag).permit(:title, :body)
  end

  def find_resource
    if params[:id]
      @tag = ActsAsTaggableOn::Tag.find params[:id]
    elsif params[:tag_name]
      @tag = ActsAsTaggableOn::Tag.find_by name: params[:tag_name]
    else
      @tag = ActsAsTaggableOn::Tag.all
    end
  end

end