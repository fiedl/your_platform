namespace :import do
  task :users => [:environment, :predefined_users] do

    # Load the UserImporter class. 
    # This really needs to be here, inside the task block. Otherwise the environment's 
    # models etc. are not available to the UserImporter instance.
    #
    require 'importers/user_importer'
    
    importer = UserImporter.new( filename: "import/netenv_data/2014-01-31/wingolf_users.csv", 
                                 # filter: { last_name: "Fiedlschuster" }
                                 # filter: { w_nummer: 'W55193' }
                                 continue_with: 'W55193'
                                 # filter: { first_name: "Thomas", last_name: "Fischer", w_nummer: 'W51809' }
                                 )
    
    importer.import

  end
  
  task :predefined_users => [:environment] do
  
    require 'importers/models/log'
    Log.new.section "Reserving vip seats."
    
    create_user(id: 1,  first_name: "Eternal", last_name: "Mystery", :alias => "mystery").try(:destroy)
    create_user(id: 2,  first_name: "Eternal", last_name: "Mystery", :alias => "W64742").try(:update_attribute, :w_nummer, "W64742")
    create_user(id: 3,  first_name: "Eternal", last_name: "Mystery", :alias => "ani").try(:destroy)
    create_user(id: 10, first_name: "Eternal", last_name: "Mystery", :alias => "W64410").try(:update_attribute, :w_nummer, "W64410")
    create_user(id: 22, first_name: "Eternal", last_name: "Mystery", :alias => "W53838").try(:update_attribute, :w_nummer, "W53838")
    create_user(id: 42, first_name: "Eternal", last_name: "Mystery", :alias => "W64744").try(:update_attribute, :w_nummer, "W64744")
    
    print "ok.\n"
    
  end
  
  def create_user(attrs = {})
    unless User.where(id: attrs[:id]).present? || ( attrs[:alias].present? && User.identify(attrs[:alias]) )
      new_user = User.new
      attrs.each do |key, value|
        new_user.send("#{key}=", value)
      end
      new_user.save!
      return new_user
    end
  end
  
end
