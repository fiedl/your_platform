namespace :cache do
  require 'colored'

  desc "For all users call the cached methods to load the value in the cache"
  task users: :environment do
    require File.join(Rails.root, 'app/models/user')
    require File.join(Rails.root, 'vendor/engines/your_platform/app/models/user')

    print "\nFor all users call the cached methods to load the value in the cache.\n".cyan
    puts "There are #{User.count} users in total now."

    User.all.each do |user|
      print ".".yellow
      user.cached_aktivitaetszahl
      #user.cached_last_group_in_first_corporation
      print ".".green
    end
   
    puts ""
    puts "The cache is filled."

  end
end
