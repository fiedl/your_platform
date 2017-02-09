class RemoveTermFromTerms < ActiveRecord::Migration
  def change
    remove_column :terms, :term
  end
end
