require 'spec_helper'

feature "Groups Page" do
  include SessionSteps
  
  describe 'when logged in as regular user' do
    background do
      login(:user)
    end
  
    scenario 'viewing the members list of a corporation' do
      @user = create(:user)
      @corporation = create(:wingolf_corporation).becomes(Group)
      @membership = @corporation.becomes(Corporation).status_groups.first.assign_user @user, at: 1.year.ago
      @former_members = @corporation.descendant_groups.find_by_flag(:former_members_parent)
        
      visit group_path(@corporation)

      page.should have_text @user.last_name
    
      # The list should not contain former members.
      #
      @membership.promote_to @former_members, at: 10.days.ago
      visit group_path(@corporation)
      page.should have_no_text @user.last_name
    end
  end

end