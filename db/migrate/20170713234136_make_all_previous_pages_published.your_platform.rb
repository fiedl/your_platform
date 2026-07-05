# This migration comes from your_platform (originally 20170713233845)
class MakeAllPreviousPagesPublished < ActiveRecord::Migration[4.2]
  def up
    # Not needed anymore for fresh installs.
    #
    # # Page.connection.execute "update pages as p set p.published_at = p.created_at where true"
  end
  def down
  end
end
