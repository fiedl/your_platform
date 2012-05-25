
set :branch, "master"


require 'colored'

namespace :deploy do
  
  desc "Prevent accidental master deployment by asking for confirmation"
  task :confirm_master_deploy do
    unless Capistrano::CLI.ui.ask( "
=============================
MASTER DEPLOYMENT
=============================

Are you sure you want to deploy the master branch? 
This will replace the current production environment! 
Thousands of users will be affected by this. (Yes, no)".red ) == "Yes"
      puts "Exiting."
      exit
    end
  end

end

before :deploy, "deploy:confirm_master_deploy"

