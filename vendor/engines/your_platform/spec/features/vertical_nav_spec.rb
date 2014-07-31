require 'spec_helper'

feature 'Vertical Navigation' do
  include SessionSteps
  
  before { login :user }
  
  scenario 'verify corporation names in menu when visiting collection groups' do
    @corporation = create :corporation, name: "Some Corporation"
    @status_group = @corporation.child_groups.create(name: "Status Group")
    @collection_group = create :group
    @collection_group.child_groups << @status_group
    
    @status_group.cached_corporation.should == @corporation
    
    visit group_path(@corporation)
    within('.vertical_menu') do
      page.should have_text "Status Group"
      page.should have_no_text "Status Group (Some Corporation)"
    end
    
    visit group_path(@collection_group)
    within('.vertical_menu') do
      page.should have_text "Status Group (Some Corporation)"
    end
  end
end
