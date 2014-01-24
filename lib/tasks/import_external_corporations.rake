namespace :import do
  
  desc "Import external corporations"
  task :external_corporations => [ 'environment', 'bootstrap:all' ] do

    require 'importers/external_corporations_importer'
    
    importer = ExternalCorporationsImporter.new( 
      filename: "import/external_corporations.csv"
    )
    importer.import
    
    # Nachdem die externen Korporationen importiert sind, muss der folgende Task
    # erneut ausgeführt werden, um deren Sub-Struktur zu importieren. Andernfalls
    # können die Status-Lebensläufe nicht korrekt abgebildet werden.
    #
    Rake::Task['import:corporations:import_sub_structure_of_wingolf_am_hochschulort_groups'].reenable
    Rake::Task['import:corporations:import_sub_structure_of_wingolf_am_hochschulort_groups'].invoke

  end
end
