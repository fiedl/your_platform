class AddStatusStatisticsToTermInfos < ActiveRecord::Migration[4.2]
  def change
    add_column :term_infos, :anzahl_aktivmeldungen, :integer
    add_column :term_infos, :anzahl_aller_aktiven, :integer
    add_column :term_infos, :anzahl_burschungen, :integer
    add_column :term_infos, :anzahl_burschen, :integer
    add_column :term_infos, :anzahl_fuxen, :integer
    add_column :term_infos, :anzahl_aktiver_burschen, :integer
    add_column :term_infos, :anzahl_inaktiver_burschen_loci, :integer
    add_column :term_infos, :anzahl_inaktiver_burschen_non_loci, :integer
    add_column :term_infos, :anzahl_konkneipwanten, :integer
    add_column :term_infos, :anzahl_philistrationen, :integer
    add_column :term_infos, :anzahl_philister, :integer
    add_column :term_infos, :anzahl_austritte, :integer
    add_column :term_infos, :anzahl_austritte_aktive, :integer
    add_column :term_infos, :anzahl_austritte_philister, :integer
    add_column :term_infos, :anzahl_todesfaelle, :integer
  end
end
