# This migration comes from your_platform (originally 20170117082552)
class AddBalanceToTermInfos < ActiveRecord::Migration[4.2]
  def change
    add_column :term_infos, :balance, :integer
  end
end
