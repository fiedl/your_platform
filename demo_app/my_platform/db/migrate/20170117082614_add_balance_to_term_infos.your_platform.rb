# This migration comes from your_platform (originally 20170117082552)
class AddBalanceToTermInfos < ActiveRecord::Migration
  def change
    add_column :term_infos, :balance, :integer
  end
end
