namespace :import do
  
  desc "Import external corporations"
  task :external_corporations => [
    'environment', 
    'bootstrap:all',
    'external_corporations:perform_import',
    'corporations:import_sub_structure_of_wingolf_am_hochschulort_groups'
  ]
  
  namespace :external_corporations do
    task :perform_import do
      require 'importers/external_corporations_importer'
      
      importer = ExternalCorporationsImporter.new( 
        filename: "import/external_corporations.csv",
        update_policy: :update
        # filter: { "token" => "La" },  
      )
      importer.import
    end
  end
end
