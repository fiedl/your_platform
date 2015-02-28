class AddAuthorToPage < ActiveRecord::Migration
  def change
    add_column :pages, :author_user_id, :integer
  end
end
