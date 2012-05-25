
require 'bundler/capistrano'

set :application, "wingolfsplattform"
set :repository,  "git@github.com:fiedl/wingolfsplattform.git"
set :branch, "testing-aki"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

server "ruby.deiszner.de", :web, :app, :db, :primary => true

#role :web, "your web-server here"                          # Your HTTP server, Apache/etc
#role :app, "your app-server here"                          # This may be the same as your `Web` server
#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

set :user, "rubyuser"
set :group, "users"
ssh_options[:keys] = "~/.ssh/id_rsa"

set :deploy_to, "/var/wingolfsplattform"
set :use_sudo, false

set :deploy_via, :copy
set :copy_strategy, :export

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  
  desc "Restart the application"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "Copy local database.yml for this stage onto the server"
  task :copy_stage_database_yml_onto_server, :roles => :app do
    upload "config/database_#{stage}.yml", "{shared_path}/config/database.yml"
  end
  
  desc "Ln database.yml into current release"
  task :ln_database_yml_into_current_release, roles => :app do
    run "ln -s #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
  end
end

before "deploy:assets:precompile", "deploy:ln_database_yml_into_current_release"

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
