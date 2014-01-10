
namespace :import do
  task users: :environment do

    # Load the UserImporter class. 
    # This really needs to be here, inside the task block. Otherwise the environment's 
    # models etc. are not available to the UserImporter instance.
    #
    # require 'importers/user_importer'
    # 
    # importer = UserImporter.new( filename: "import/netenv_data/Members_production_2012-01-17.csv",
    #                              update_policy: :update,
    #                              #filter: { "uid" => "W51451" },
    #                              # Büscher: W64185, Fiedlschuster: W64742
    #                              )
    # importer.import
    
    require 'importers/user_importer'
    
    importer = UserImporter.new( filename: "import/netenv_data/Members_production_2012-01-17.csv", 
                                 filter: { last_name: "Fiedlschuster" }
                                 # filter: { w_nummer: 'W53167' }
                                 # filter: { first_name: "Thomas", last_name: "Fischer" }
                                 )
    
    importer.import
    
    

  end
end
