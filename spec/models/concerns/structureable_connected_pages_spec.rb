require 'spec_helper'

describe StructureableConnectedPages do
  
  #
  # @group
  #   |
  # @page --- @subpage
  #              |
  #           @disconnected_group
  #              |
  #           @disconnected_group_page
  #
  before do
    @group = create :group, name: 'group'
    @page = @group.child_pages.create name: 'page'
    @subpage = @page.child_pages.create name: 'subpage'
    @disconnected_group = @subpage.child_groups.create name: 'disconnected_group'
    @disconnected_group_page = @disconnected_group.child_pages.create name: 'disconnected_group_page'
  end
  
  describe "#conncted_descendant_pages" do
    subject { @group.connected_descendant_pages }
    it { should include @page }
    it { should include @subpage }
    it { should_not include @disconnected_group_page }
  end    
  
end