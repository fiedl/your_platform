# This migration comes from your_platform (originally 20170115053544)
class AddTypeToTerms < ActiveRecord::Migration
  def change
    add_column :terms, :type, :string
  end
end
