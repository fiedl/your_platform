
require 'bundler/capistrano'
require 'capistrano_colors'

set :stages, %w(testing-aki testing-pub production)
set :default_stage, "testing-aki"
require 'capistrano/ext/multistage'

set :application, "wingolfsplattform"
set :repository,  "git@github.com:fiedl/wingolfsplattform.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

#role :web, "your web-server here"                          # Your HTTP server, Apache/etc
#role :app, "your app-server here"                          # This may be the same as your `Web` server
#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

ssh_options[:keys] = "~/.ssh/id_rsa"

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

#  desc "Copy local database.yml for stage onto the server"
#  task :copy_stage_database_yml_onto_server, :roles => :app do
#    #upload "config/database/database_#{stage}.yml", "#{shared_path}/config/database.yml"
#    upload "config/database/database_testing-aki.yml", "#{shared_path}/config/database.yml"
#  end
  
  desc "ln database.yml into current release"
  task :ln_database_yml_into_current_release, :roles => :app do
#    upload "config/database/database_testing-aki.yml", "#{shared_path}/config/database.yml"
    Capistrano::CLI.ui.say "TODO UPLOAD DATABASE YML FILE!"
    run "ln -s #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
  end
end

before "deploy:assets:precompile", "deploy:ln_database_yml_into_current_release"
#before "deploy:ln_database_yml_into_current_release", "deploy:copy_stage_database_yml_onto_server"

