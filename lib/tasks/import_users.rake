
namespace :import do
  task users: :environment do

    # Load the UserImporter class. 
    # This really needs to be here, inside the task block. Otherwise the environment's 
    # models etc. are not available to the UserImporter instance.
    #
    require 'importers/user_importer'

    importer = UserImporter.new( file_name: "import/deleted-string_data/Members_production_2012-01-17.csv",
                                 update_policy: :update,
                                 #filter: { "uid" => "W51451" },
                                 filter: { "uid" => "W53003" },  
                                 # Büscher: W64185, Fiedlschuster: W64742
                                 )
    importer.import

  end
end
