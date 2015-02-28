require 'spec_helper'

describe NavNode do
  before do
    # Since Users, Pages, Groups, etc. are Navables, i.e. have NavNodes associated,
    # we here just pick the NavNode of a Page.
    @page = create(:page, title: "My Page")
    @nav_node = @page.nav_node
    @nav_node.save
  end
  subject { @nav_node }
  
  describe "#url_component" do
    subject { @nav_node.url_component }
    describe "for no url_component set" do
      it "should use the navable's title for generation" do
        subject.should == "my-page/"
      end
    end
    describe "for a url_component set" do
      before do
        @nav_node.url_component = "foo/"
      end
      it "should use the customized setting" do
        subject.should == "foo/"
      end
    end
  end
  describe "#url_component=" do
    subject { @nav_node.url_component = "foo/" }
    it "should override the default setting" do
      @nav_node.url_component.should_not == "foo/"
      subject
      @nav_node.url_component.should == "foo/"
    end
    it "should persist after saving" do
      @nav_node.url_component.should_not == "foo/"
      subject
      @nav_node.save
      @reloaded_nav_node = NavNode.find(@nav_node.id)
      @reloaded_nav_node.url_component.should == "foo/"
    end
  end
  
  describe "#breadcrumb_item" do
    subject { @nav_node.breadcrumb_item }
    describe "for no breadcrumb_item set" do
      it "should use the navable's title for generation" do
        subject.should == "My Page"
      end
    end
    describe "for a breadcrumb_item set" do
      before do
        @nav_node.breadcrumb_item = "Foo"
      end
      it "should use the customized setting" do
        subject.should == "Foo"
      end
    end
  end
  describe "#breadcrumb_item=" do
    subject { @nav_node.breadcrumb_item = "Foo" }
    it "should override the default setting" do
      @nav_node.breadcrumb_item.should_not == "Foo"
      subject
      @nav_node.breadcrumb_item.should == "Foo"
    end
    it "should persist after saving" do
      @nav_node.breadcrumb_item.should_not == "Foo"
      subject
      @nav_node.save
      @reloaded_nav_node = NavNode.find(@nav_node.id)
      @reloaded_nav_node.breadcrumb_item.should == "Foo"
    end
  end
  
  describe "#menu_item" do
    subject { @nav_node.menu_item }
    describe "for no menu_item set" do
      it "should use the navable's title for generation" do
        subject.should == "My Page"
      end
    end
    describe "for a menu_item set" do
      before do
        @nav_node.menu_item = "Foo"
      end
      it "should use the customized setting" do
        subject.should == "Foo"
      end
    end
  end
  describe "#menu_item=" do
    subject { @nav_node.menu_item = "Foo" }
    it "should override the default setting" do
      @nav_node.menu_item.should_not == "Foo"
      subject
      @nav_node.menu_item.should == "Foo"
    end
    it "should persist after saving" do
      @nav_node.menu_item.should_not == "Foo"
      subject
      @nav_node.save
      @reloaded_nav_node = NavNode.find(@nav_node.id)
      @reloaded_nav_node.menu_item.should == "Foo"
    end
  end
    
  describe "#hidden_menu" do
    subject { @nav_node.hidden_menu }
    describe "for the setting being overridden" do
      it "should return the forced setting" do
        @nav_node.hidden_menu = true
        @nav_node.hidden_menu.should == true
        @nav_node.hidden_menu = false
        @nav_node.hidden_menu.should == false
      end
    end
    describe "for Pages, by default" do
      before { @nav_node = create(:page).nav_node }
      it { should == false }
    end
    describe "for Groups, by default" do
      before { @nav_node = create(:group).nav_node }
      it { should == false }
    end
    describe "for :officers_parent groups, by default" do
      before { @nav_node = create(:group).find_or_create_officers_parent_group.nav_node }
      it { should == true }
    end
    describe "for Users, by default" do
      before { @nav_node = create(:user).nav_node }
      it { should == true }
    end
    describe "for Events, by default" do
      before { @nav_node = create(:event).nav_node }
      it { should == true }
    end
    # 
    # TODO: Later, when Workflows are Navables, use this:
    #
    # describe "for Workflows, by default" do
    #   before { @nav_node = create(:workflow).nav_node }
    #   it { should == true }
    # end
    # 
    # For the moment:
    #
    describe "for Workflows, by default" do
      specify "Workflows are not Navable at the moment, thus do not respond to #nav_node" do
        create(:workflow).should_not respond_to :nav_node
      end
    end
  end
  
  describe "#slim_breadcrumb" do
    subject { @nav_node.slim_breadcrumb }
    describe "for being set to true" do
      before { @nav_node.slim_breadcrumb = true }
      it { should == true }
    end
    describe "for being set to false" do
      before { @nav_node.slim_breadcrumb = false }
      it { should == false }
    end
    describe "for not being set" do
      it { should == false }
    end
  end
  
  describe "(route methods)" do
    before do
      @root_page = create(:page, title: "Example.com")
      @root_page.nav_node.update_attribute(:url_component, "http://example.com/")
      @products_page = create(:page, title: "Products")
      @products_page.parent_pages << @root_page
      @phones_page = create(:page, title: "Phones")
      @phones_page.parent_pages << @products_page
      
      @nav_node = @phones_page.nav_node
    end
  
    describe "#url" do
      subject { @nav_node.url }
      it "should return the joined url" do
        subject.should == "http://example.com/products/phones"
      end
      it "should remove the trailing slash (/)" do
        subject.should_not end_with "/"
      end
    end
  
    describe "#breadcrumbs" do
      subject { @nav_node.breadcrumbs }
      it "should return an Array of Hashes" do
        subject.should be_kind_of Array
        subject.first.should be_kind_of Hash
      end
      specify "the Hash's attributes :title, :navable and :slim should be set" do
        subject.first[:title].should_not == nil
        subject.first[:navable].should_not == nil
        subject.first[:slim].should_not == nil        
      end
      it { should == [ {title: "Example.com", navable: @root_page, slim: false},
                       {title: "Products", navable: @products_page, slim: false},
                       {title: "Phones", navable: @phones_page, slim: false} ] }
    end
  
    describe "#ancestor_navables" do
      subject { @nav_node.ancestor_navables }
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
      
          @nav_node = @phones_page.nav_node
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

    describe "#ancestor_navables_and_own" do
      it { should = [ @root_page, @products_page, @phone_page ] }
    end 

    describe "#ancestor_nodes" do
      subject { @nav_node.ancestor_nodes }
      it "should be an Array of NavNodes" do
        subject.should be_kind_of Array
        subject.first.should be_kind_of NavNode
      end
      it "should return the NavNodes of the Navable's ancestors" do
        # use .to_s since these are, in fact, different objects in memory.
        subject.to_s.should == [ @root_page.nav_node, @products_page.nav_node ].to_s
      end
    end
    
    describe "#ancestor_nodes_and_self" do
      subject { @nav_node.ancestor_nodes_and_self }
      it "should return an Array of the ancestor_nodes plus this NavNode as the last element" do
        subject.to_s.should == [ @root_page.nav_node, @products_page.nav_node, @nav_node ].to_s
      end
    end
    
  end
end
