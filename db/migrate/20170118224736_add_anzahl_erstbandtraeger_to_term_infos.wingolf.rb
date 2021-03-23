class AddAnzahlErstbandtraegerToTermInfos < ActiveRecord::Migration[4.2]
  def change
    add_column :term_infos, :anzahl_erstbandtraeger_aktivitas, :integer
    add_column :term_infos, :anzahl_erstbandtraeger_philisterschaft, :integer
  end
end
