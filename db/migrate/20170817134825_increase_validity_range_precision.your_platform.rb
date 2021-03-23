# This migration comes from your_platform (originally 20170727152732)
class IncreaseValidityRangePrecision < ActiveRecord::Migration[5.0]
  def change
    # Not needed anymore for fresh installs.
    #
    # # DagLink.where(valid_to: 0).update_all valid_to: nil

    change_column :dag_links, :valid_from, :datetime, limit: 6
    change_column :dag_links, :valid_to, :datetime, limit: 6
  end
end
