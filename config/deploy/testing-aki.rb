
# capistrano environment configuration
# testing-aki

set :branch, "testing-aki"

server "ruby.deiszner.de", :web, :app, :db, :primary => true

set :user, "rubyuser"
set :group, "users"
set :deploy_to, "/var/wingolfsplattform"
set :use_sudo, false

set :default_environment, {
  'PATH' => "$PATH:/home/rubyuser/.gem/ruby/1.9.1/bin",
  'RAILS_ENV' => "testing-aki"
}
