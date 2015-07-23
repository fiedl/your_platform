require 'spec_helper'

feature "Merit Point Rules" do
  include SessionSteps
  
  background do
    @user = create :user_with_account
    @points = @user.points
    @group = create(:group)
    @event1 = @group.child_events.create name: "Gamification Hacking Workshop", start_at: 1.day.from_now
    @event2 = @group.child_events.create name: "Another meeting", start_at: 10.day.from_now
    @group.assign_user @user, at: 1.year.ago
   end
  
  scenario "joining event earns 1 point" do
    login @user

    # Just looking at events#index does nothing.
    visit root_path
    @user.reload.points.should == @points

    # Joining an event should add a point.
    visit root_path
    within('.box.upcoming_events') { click_on @event1.name }
    page.should have_selector '#join_event', visible: true
    find('#join_event').click
    @user.reload.points.should == @points+1
    within('.box.upcoming_events') { click_on @event2.name }
    page.should have_selector '#join_event', visible: true
    find('#join_event').click
    @user.reload.points.should == @points+2
  end
  
end
