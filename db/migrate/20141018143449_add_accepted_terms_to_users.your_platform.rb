# This migration comes from your_platform (originally 20141018143323)
class AddAcceptedTermsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :accepted_terms, :string
    add_column :users, :accepted_terms_at, :datetime
  end
end
