require 'spec_helper'

describe PagePublicWebsite do
  
  # Page.find_root (:root)          < 
  #      |------ public_page_1      < public website
  #      |------ public_page_2      <
  #      |
  #      |------ Page.find_intranet_root (:intranet_root)
  #      |                |-------- internal_page_1
  #                                    |---- internal_page_2
  #
  before do
    @root = Page.find_or_create_root
    @intranet_root = Page.find_or_create_intranet_root
    @public_page_1 = @root.child_pages.create
    @public_page_2 = @root.child_pages.create
    @internal_page_1 = @intranet_root.child_pages.create
    @internal_page_2 = @internal_page_1.child_pages.create
    
    Page.public_website_page_ids(true)
  end
  
  specify "prelims" do
    @root.child_pages.should include @intranet_root
  end
  
  describe ".public_website_page_ids" do
    subject { Page.public_website_page_ids }
    it { should include @root.id }
    it { should include @public_page_1.id, @public_page_2.id }
    it { should_not include @intranet_root.id }
    it { should_not include @internal_page_1.id, @internal_page_2.id }
  end
  
  describe ".public_website (scope)" do
    subject { Page.public_website }
    it { should include @root }
    it { should include @public_page_1, @public_page_2 }
    it { should_not include @intranet_root }
    it { should_not include @internal_page_1, @internal_page_2 }
  end
  
end