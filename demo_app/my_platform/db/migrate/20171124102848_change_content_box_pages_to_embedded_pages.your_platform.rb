# This migration comes from your_platform (originally 20171124102624)
class ChangeContentBoxPagesToEmbeddedPages < ActiveRecord::Migration[5.0]
  def up
    Page.where(type: "Pages::ContentBox").update_all type: nil, embedded: true
  end
  def down
    Page.where(embedded: true).update_all type: "Pages::ContentBox"
  end
end
