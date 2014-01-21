namespace :import do
  
  desc "Import external corporations (Falkensteiner Bund)"
  task :external_corporations => ['environment', 'bootstrap:all'] do

    require 'importers/external_corporations_importer'

    importer = ExternalCorporationsImporter.new( 
      filename: "import/external_corporations.csv",
      update_policy: :update
      # filter: { "token" => "La" },  
    )
    importer.import

  end
end
