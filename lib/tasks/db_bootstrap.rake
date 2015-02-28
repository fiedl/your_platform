#
# These tasks allow to perform a basic database bootstrap, i.e.
# generate some basic pages and groups.
#
# Execute by `bundle exec rake your_platform:db:bootstrap`.
#

namespace :your_platform do
  namespace :db do
    task :bootstrap => :environment do

      # Group 'Everyone'.
      # Every user is a member of this group.
      Group.create_everyone_group unless Group.everyone
      Group.find_everyone_group.create_nav_node(slim_menu: true, slim_breadcrumb: true)

      # Corporations Parent Group.
      # Your local organizations are children of this group. 
      Group.create_corporations_parent_group unless Group.corporations_parent
      Group.find_corporations_parent_group.create_nav_node(slim_menu: true, slim_breadcrumb: true)

      # Root page.
      # This, most probably, will be named after your organization's public
      # homepage's url. 
      root_page = Page.create(title: "example.org", redirect_to: "http://example.org")
      root_page.add_flag :root
      root_page.create_nav_node(slim_menu: true)

      # Intranet root page.
      # This is the start page of the intranet you are creating with your_platform.
      intranet_root_page = root_page.child_pages.create(title: Rails.application.class.parent_name)
      intranet_root_page.add_flag :intranet_root
      intranet_root_page.child_groups << Group.find_everyone_group

    end
  end
end
