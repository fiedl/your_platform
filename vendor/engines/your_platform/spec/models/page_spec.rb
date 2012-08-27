require 'spec_helper'

describe Page do

  def create_page_structure
    Page.destroy_all # in case there are already pages defined elsewhere
    @root = create( :page, title: "Root" )
    @intranet_root = create( :page, title: "Intranet Root" )
    @some_page = create( :page, title: "Some Page" )

    @intranet_root.add_flag( :intranet_root )

    @root.child_pages << @intranet_root
    @intranet_root.child_pages << @some_page
  end  

  subject { create( :page ) }


  # General Properties
  # ----------------------------------------------------------------------------------------------------

  it { should respond_to( :content, :content=, :title, :title= ) }
  
  it "should be structureable" do
    subject.should respond_to( :parents, :children, :ancestors, :descendants )
  end

  it "should be navable" do
    subject.should respond_to( :nav_node )
  end

  it "should have attachments" do
    subject.should respond_to( :attachments )
    subject.attachments.should == []
  end


  # Association Related Methods
  # ----------------------------------------------------------------------------------------------------

  describe "#attachments_by_type" do
    it "should be the same as #attachments.find_by_type" do
      type = "image"
      subject.attachments_by_type( type ).should == subject.attachments.find_by_type( type )
    end
  end


  # Finder Methods
  # ----------------------------------------------------------------------------------------------------

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
