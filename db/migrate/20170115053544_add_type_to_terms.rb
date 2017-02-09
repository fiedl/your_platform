class AddTypeToTerms < ActiveRecord::Migration
  def change
    add_column :terms, :type, :string
  end
end
