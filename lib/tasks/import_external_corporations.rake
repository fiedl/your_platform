namespace :import do
  task external_corporations: :environment do

    require 'importers/external_corporations_importer'

    importer = ExternalCorporationsImporter.new( 
      file_name: "import/external_corporations.csv",
      update_policy: :update
      # filter: { "token" => "La" },  
    )
    importer.import

  end
end
