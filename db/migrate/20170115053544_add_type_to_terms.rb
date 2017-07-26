class AddTypeToTerms < ActiveRecord::Migration[4.2]
  def change
    add_column :terms, :type, :string
  end
end
