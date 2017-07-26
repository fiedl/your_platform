# This migration comes from your_platform (originally 20170115055335)
class RemoveTermFromTerms < ActiveRecord::Migration[4.2]
  def change
    remove_column :terms, :term
  end
end
