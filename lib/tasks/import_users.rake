
namespace :import do
  task users: :environment do

    # Load the UserImporter class. 
    # This really needs to be here, inside the task block. Otherwise the environment's 
    # models etc. are not available to the UserImporter instance.
    #
    require 'importers/user_importer'
    
    importer = UserImporter.new( filename: "import/netenv_data/Members_production_2012-01-17.csv", 
                                 # filter: { last_name: "Fiedlschuster" }
                                 # filter: { w_nummer: 'W51343' }
                                 continue_with: 'W51343'
                                 # filter: { first_name: "Thomas", last_name: "Fischer", w_nummer: 'W51809' }
                                 )
    
    importer.import

  end
end
