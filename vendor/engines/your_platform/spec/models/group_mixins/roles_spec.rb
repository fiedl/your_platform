require 'spec_helper'

describe GroupMixins::Roles do

  describe "#administrated_object" do
    before do
      @some_group = create( :group )
      @sub_group = create( :group ); @sub_group.parent_groups << @some_group
      @officers_parent = @sub_group.create_officers_parent_group
      @admins_parent = @sub_group.find_or_create_admins_parent_group
      @main_admins_parent = @sub_group.create_main_admins_parent_group
    end
    context "for an officers_parent_group" do
      subject { @officers_parent.administrated_object }
      it "should be the parent of the officers_parent" do
        subject.should == @sub_group
      end
    end
    context "for a child group of the officers_parent_group" do
      subject { @main_admins_parent.administrated_object }
      it "should be the parent of the officers_parent as well" do
        subject.should == @sub_group
      end
    end
    context "for the administrated object itself" do
      subject { @sub_group.administrated_object }
      it { should == nil }
    end
    context "for a parent of the aministrated object" do
      subject { @some_group.administrated_object }
      it { should == nil }
    end
    context "for the administrated object being something different than a group" do
      before do
        @some_page = create( :page )
        @main_admins_parent = @some_page.create_main_admins_parent_group
      end
      subject { @main_admins_parent.administrated_object }
      it "should work as well" do
        subject.should == @some_page
      end
    end

  end  

end
