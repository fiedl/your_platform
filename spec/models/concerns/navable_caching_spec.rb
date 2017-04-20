require 'spec_helper'

describe NavableCaching do
  before do
    @root = Page.find_root
    @root.title = "example.com"
    @root.save
    @intranet_root = Page.find_intranet_root
  end

  describe "#ancestor_navables" do
    subject { @intranet_root.ancestor_navables }

    specify "prerequisites" do
      @intranet_root.ancestor_navables.should include @root
      @intranet_root.ancestor_navables.map(&:title).should include "example.com"
    end

    describe "after changing the ancestor's title" do
      before { @root.title = "foo.com"; @root.save }

      it "should reflect the new ancestor title" do
        subject.map(&:title).should include "foo.com"
      end
    end
  end

  describe "#breadcrumbs" do
    describe "#first" do
      describe "#breadcrumb_title" do
        subject { @intranet_root.breadcrumbs.first.breadcrumb_title }

        it { should == "example.com"}
        describe "after changing the ancestor's title" do
          before { @root.title = "foo.com"; @root.save }
          it { should == "foo.com" }
        end
      end
    end
  end
end