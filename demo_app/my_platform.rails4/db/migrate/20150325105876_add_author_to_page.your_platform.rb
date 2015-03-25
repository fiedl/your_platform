# This migration comes from your_platform (originally 20130409192959)
class AddAuthorToPage < ActiveRecord::Migration
  def change
    add_column :pages, :author_user_id, :integer
  end
end
