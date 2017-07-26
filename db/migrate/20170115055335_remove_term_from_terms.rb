class RemoveTermFromTerms < ActiveRecord::Migration[4.2]
  def change
    remove_column :terms, :term
  end
end
