class VororteController < ApplicationController

  expose :page, -> { Page.flagged(:vorort).first_or_create { |page| page.title = "Vorort des Wingolfsbundes"; page.save; page.add_flag(:vorort) } }
  expose :offices, -> { OfficerGroup.where(name: "Bundeschargierte").first.child_groups }
  expose :post_recipient_group, -> { OfficerGroup.flagged(:bundeschargen).first }

  expose :post_sent_via, -> { "vorort-page" }
  expose :post, -> {
    draft = current_user.drafted_posts.where(sent_via: post_sent_via).first_or_create
    draft.parent_groups << post_recipient_group unless post_recipient_group.in? draft.parent_groups
    draft
  }

  expose :posts, -> {
    post_recipient_group.posts.published
      .where(author_user_id: current_user.id)
      .order(sticky: :asc, updated_at: :desc)
      .limit(10)
  }

  def show
    authorize! :read, page

    set_current_navable page
    set_current_title page.title
    set_current_tab :contacts
  end

end