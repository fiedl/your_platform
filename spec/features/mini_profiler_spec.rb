require 'spec_helper'

# This specs are deactivated intentionally.
# See comments in config/initialiers/mini_profiler.rb.

# feature "MiniProfiler", :js do
#   include SessionSteps
#   
#   describe "for a user being a developer" do
#     background do
#       @developer_user = create(:user_with_account)
#       @developer_user.developer = true
#       login(@developer_user)
#     end
#     scenario 'Make sure the MiniProfiler is properly initialized' do
#       Rack::MiniProfiler.config.pre_authorize_cb[:production].should == true
#       Rack::MiniProfiler.config.pre_authorize_cb[:test].should == true
#     end
#     scenario 'Visiting any page displays the MiniProfiler tool in the upper left corner of the browser.' do
#       visit root_path
#       wait_for_ajax
#       page.should have_selector ".profiler-results.profiler-left", visible: true
#     end
#   end
#   
#   describe "for a regular user" do
#     background do
#       login(:user)
#     end
#     scenario 'Visiting any page does not display the MiniProfiler tool.' do
#       visit root_path
#       wait_for_ajax
#       page.should have_no_selector ".profiler-results.profiler-left"
#     end
#   end
#   
# end
