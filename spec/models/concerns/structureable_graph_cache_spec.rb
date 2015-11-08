require 'spec_helper'

describe StructureableGraphCache do
  
  # 
  #   @root_page
  #      |
  #   @intranet_root_page
  #      |
  #   @everyone_group
  #      |
  #   @corporations_group
  #      |------------------ @berlin_corporation
  #      |
  #   @erlangen_corporation
  #      |------------------ @philisterschaft_group
  #      |
  #   @aktivitas_group
  #      |------------------ @fuxen_group --------- @fux_user
  #      |------------------ @burschen_group ------ @burschen_protokolle_page
  #      |------------------ @protokolle_pages ---- @protokolle_sub_page
  #      |
  #   @officers_parent_group
  #      |
  #   @chargen_group
  #      |
  #   @senior_group
  #
  before do
    @root_page = Page.find_root
    @intranet_root_page = Page.find_intranet_root; @root_page << @intranet_root_page
    @everyone_group = Group.everyone; @intranet_root_page << @everyone_group
    @corporations_group = Group.corporations_parent; @everyone_group << @corporations_group
    @berlin_corporation = create :corporation, name: "Berlin"
    @erlangen_corporation = create :corporation, name: "Erlangen"
    @philisterschaft_group = @erlangen_corporation.child_groups.create name: "Philisterschaft"
    @aktivitas_group = @erlangen_corporation.child_groups.create name: "Aktivitas"
    @fuxen_group = @aktivitas_group.child_groups.create name: "Fuxen"
    @burschen_group = @aktivitas_group.child_groups.create name: "Burschen"
    @protokolle_page = @aktivitas_group.child_pages.create title: "Protokolle"
    @protokolle_sub_page = @protokolle_page.child_pages.create title: "Protokolle WS 2015/16"
    @burschen_protokolle_page = @burschen_group.child_pages.create title: 'burschen_protokolle_page'
    @officers_parent_group = @aktivitas_group.officers_parent
    @chargen_group = @officers_parent_group.child_groups.create name: "Chargen"
    @senior_group = @chargen_group.child_groups.create name: "Chargen"
    @fux_user = create :user; @fuxen_group.assign_user @fux_user
  end
  
  describe "requirements" do
    describe "@everyone_group.connected_descendant_groups" do
      subject { @everyone_group.connected_descendant_groups }
      it { should include @corporations_group, @berlin_corporation, @erlangen_corporation, @aktivitas_group, @philisterschaft_group, @fuxen_group, @burschen_group }
      it { should_not include @chargen_group, @senior_group }
      it { should_not include @officers_parent_group }
    end
  end
  
  describe "#affected_nodes_after_officer_has_changed" do
    subject { @aktivitas_group.affected_nodes_after_officer_has_changed }
    it { should include @fuxen_group, @burschen_group }
    it { should include @protokolle_page, @protokolle_sub_page }
    it { should include @burschen_protokolle_page }
    it { should_not include @everyone_group, @corporations_group, @erlangen_corporation, @berlin_corporation }
    it { should_not include @philisterschaft_group }
    it { should_not include @root_page, @intranet_root_page }
    it { should_not include @officers_parent_group, @chargen_group, @senior_group }
    it { should include @fux_user }
  end
  
end