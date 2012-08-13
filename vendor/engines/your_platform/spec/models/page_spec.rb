require 'spec_helper'

describe Page do

  def create_page_structure
    @root = Page.create( title: "Root" )
    @intranet_root = Page.create( title: "Intranet Root" )
    @some_page = Page.create( title: "Some Page" )

    @intranet_root.add_flag( :intranet_root )

    @root.child_pages << @intranet_root
    @intranet_root.child_pages << @some_page
  end  

  describe "#find_root" do
    before { create_page_structure }
    subject { Page.find_root }

    it "should return the root page" do
      subject.should == @root
    end
  end

  describe "#find_intranet_root" do
    before { create_page_structure }
    subject { Page.find_intranet_root }
    
    it "should return the intranet root page" do
      subject.should == @intranet_root 
    end
  end

end
