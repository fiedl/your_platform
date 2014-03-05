require 'spec_helper'

describe HorizontalNav do
  
  before do
    @user = create(:user)
    @corporation_a = create(:wah_group)
    @corporation_b = create(:wah_group)
    @bv = create(:bv_group)
    
    @horizontal_nav = HorizontalNav.new(user: @user, current_navable: Page.find_intranet_root)
  end

  describe "#navables" do
    subject { @horizontal_nav.navables }
    
    it { should include Page.find_intranet_root }
  
    describe "for the user being member of one corporation" do
      before { @corporation_a.status_group("Hospitanten") << @user }
      it { should include @corporation_a.becomes(Group) }
    end
    
    describe "for the user being member of several corporations" do
      before do
        @corporation_a.status_group("Philister") << @user
        @corporation_b.status_group("Philister") << @user
      end
      it "should include all corporations" do
        subject.should include @corporation_a.becomes(Group)
        subject.should include @corporation_b.becomes(Group)        
      end
    end
    
    describe "for the user being former member of a corporation" do
      before do
        @corporation_a.status_group("Philister") << @user
        @membership = @corporation_b.status_group("Philister").assign_user @user, at: 1.hour.ago
        @membership.move_to @corporation_b.status_group("Schlicht Ausgetretene")
      end
      it "should include the corporations the user is still member in" do
        subject.should include @corporation_a.becomes(Group)
      end
      it "should not include the former corporations" do
        subject.should_not include @corporation_b.becomes(Group)
      end
    end
    
    describe "for the user being member of a bv" do
      before { @bv << @user }
      it { should include @bv }
    end
  end
  
  describe "#cached_navables" do
    subject { @horizontal_nav.cached_navables }
    
    it { should include Page.find_intranet_root }
  
    describe "for the user being member of one corporation" do
      before { @corporation_a.status_group("Hospitanten") << @user }
      it { should include @corporation_a.becomes(Group) }
    end
    
    describe "for the user being member of several corporations" do
      before do
        @corporation_a.status_group("Philister") << @user
        @corporation_b.status_group("Philister") << @user
      end
      it "should include all corporations" do
        subject.should include @corporation_a.becomes(Group)
        subject.should include @corporation_b.becomes(Group)        
      end
    end
    
    describe "for the user being former member of a corporation" do
      before do
        @corporation_a.status_group("Philister") << @user
        @membership = @corporation_b.status_group("Philister").assign_user @user, at: 1.hour.ago
        @membership.move_to @corporation_b.status_group("Schlicht Ausgetretene")
      end
      it "should include the corporations the user is still member in" do
        subject.should include @corporation_a.becomes(Group)
      end
      it "should not include the former corporations" do
        subject.should_not include @corporation_b.becomes(Group)
      end
    end
    
    describe "for the user being member of a bv" do
      before { @bv << @user }
      it { should include @bv }
    end
    
    describe "for exiting a corporation after using the cache" do
      before do
        @corporation_a.status_group("Philister") << @user

        @horizontal_nav.cached_navables
        @membership = @corporation_b.status_group("Philister").assign_user @user, at: 1.hour.ago
        @membership.move_to @corporation_b.status_group("Schlicht Ausgetretene")
      end
      it "should have the former corporation removed from the cached navables" do
        subject.should_not include @corporation_b.becomes(Group)
      end
    end
  end
  
end

