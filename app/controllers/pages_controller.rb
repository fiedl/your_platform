class PagesController < ApplicationController
  include MarkdownHelper

  expose :page, -> { find_page_by_permalink || (Page.find(params[:id]) if params[:id]) }
  expose :attachments, -> {
    page.attachments.includes(:author, :parent)
      .find_without_types("video", "image")
      .sort_by { |attachment| attachment.created_at }.reverse
  }
  expose :blog_entries, -> { page.blog_entries.visible_to(current_user) }

  def show
    authorize! :read, page

    if (target = page.redirect_to) && target.present?

      # In order to avoid multiple redirects, we force https manually here
      # in production.
      #
      target.merge!({protocol: "https://"}) if target.kind_of?(Hash) && Rails.env.production?

      redirect_to target
      return
    end

    # Inline-convert legacy markdown pages.
    #
    if page.content == helpers.strip_tags(page.content)
      page.content = markdown page.content
    end

    set_current_navable page
    set_current_title page.title
    set_current_tab :pages
  end

  def update
    authorize! :update, page

    page.update! page_params
    render json: page, status: :ok
  end

  private

  def page_params
    params.require(:page).permit(:title, :content, :image)
  end

  def find_page_by_permalink
    page_id = Permalink.find_by(url_path: params[:permalink], reference_type: 'Page').try(:reference_id)
    Page.find(page_id) if page_id
  end

end
