require 'spec_helper'

describe Graph::Page do

  before do
    @root = Page.root
    @intranet_root = Page.intranet_root
  end

  describe "#sub_page_ids" do
    subject { Graph::Page.find(@root).sub_page_ids }

    it { should include @intranet_root.id }

    describe "when public blog posts exist" do
      before { @public_blog_post = @root.child_pages.create title: "Public Post", type: "BlogPost" }
      it { should include @public_blog_post.id }

      describe "after destroying the sub page" do
        before { @former_public_blog_post_id = @public_blog_post.id; @public_blog_post.destroy }
        it { should_not include @former_public_blog_post_id }
      end
    end

    describe "when the intranet contains a group that has its own pages" do
      before do
        @group = @intranet_root.child_groups.create name: "Some group"
        @group_content = @group.child_pages.create title: "Private group content"
      end
      it { should_not include @group_content.id }
    end
  end

end