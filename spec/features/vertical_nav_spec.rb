require 'spec_helper'

feature 'Vertical Navigation' do
  include SessionSteps
  
  before { login :user }
  
  scenario 'verify corporation names in menu when visiting collection groups' do
    @corporation = create :corporation, name: "Some Corporation"
    @another_corporation = create :corporation, name: "Other Corporation"
    
    @status_group = @corporation.child_groups.create(name: "Status Group")
    @another_status_group = @another_corporation.child_groups.create(name: "Status Group")

    @collection_group = create :group
    @collection_group.child_groups << @status_group
    @collection_group.child_groups << @another_status_group
    
    @status_group.cached(:corporation).should == @corporation
    
    visit group_path(@corporation)
    within('.vertical_menu') do
      page.should have_text "Status Group"
      page.should have_no_text "Status Group (Some Corporation)"
    end
    
    visit group_path(@collection_group)
    within('.vertical_menu') do
      page.should have_text "Status Group (Some Corporation)"
      page.should have_text "Status Group (Other Corporation)"
    end
  end
end
