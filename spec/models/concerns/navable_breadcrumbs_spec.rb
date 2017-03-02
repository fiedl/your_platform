require 'spec_helper'

describe NavableBreadcrumbs do

  describe "(route methods)" do
    before do
      @root_page = create(:page, title: "Example.com")
      @root_page.nav_node.update_attribute(:url_component, "http://example.com/")
      @products_page = create(:page, title: "Products")
      @products_page.parent_pages << @root_page
      @phones_page = create(:page, title: "Phones")
      @phones_page.parent_pages << @products_page

      @navable = @phones_page
      @nav_node = @navable.nav_node
    end

    describe "#ancestor_navables" do
      subject { @navable.ancestor_navables }
      it "should return the navable ancestors of the NavNode's Navable" do
        subject.should == [ @root_page, @products_page ]
      end
      describe "for the ancestors' ids not being in an ascending order matching the hierarchy" do
        before do

          # The @products_page is created before the @root_page on purpose.
          #
          @products_page = create(:page, title: "Products")
          @root_page = create(:page, title: "Example.com")
          @root_page.nav_node.update_attribute(:url_component, "http://example.com/")
          @products_page.parent_pages << @root_page
          @phones_page = create(:page, title: "Phones")
          @phones_page.parent_pages << @products_page

          @navable = @phones_page
          @nav_node = @navable.nav_node
        end
        it "should return the navable ancestors of the NavNode's Navable" do
          subject.should == [ @root_page, @products_page ]
        end
        describe "for ambiguous routes" do
          before do
            @other_ancestor_page = create(:page)
            @phones_page.parent_pages << @other_ancestor_page
            @nav_node = @phones_page.nav_node
          end
          it "should list only the first route" do
            #
            #   @root_page
            #       |
            #   @products_page   @other_ancestor_page
            #              |       |
            #             @phones_page
            #
            @phones_page.ancestors.should include @root_page, @products_page, @other_ancestor_page
            subject.should include @root_page, @products_page
            subject.should_not include @other_ancestor_page
          end
        end
      end
    end
  end
end