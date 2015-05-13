require 'spec_helper'

feature "Groups Page" do
  include SessionSteps


  describe 'when logged in as admin' do
    background do
      @user = create(:user, first_name: "Max", last_name: "Mustermann")
      @group = create(:group)

      login(:admin)
    end
  end

  describe 'when logged in as regular user' do
    background do
      @group = create(:group, :with_members, :with_hidden_member, :with_dead_member)
      login(:user)
    end

    scenario 'should not render list entries for hidden members' do
      visit group_path(@group)
      page.should have_selector '#group_members tr', count: 12
      page.should have_no_text 'Hidden'
    end
    
    scenario 'should render list entries for dead members' do
      visit group_path(@group)
      page.should have_selector '#group_members tr', count: 12
      page.should have_text 'Dead'
    end
  end
  
end
