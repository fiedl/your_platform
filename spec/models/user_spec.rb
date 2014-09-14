# -*- coding: utf-8 -*-
require 'spec_helper'

describe User do

  before do 
    @user = create( :user )
  end

  describe "#title" do
    before do
      @corporation = create(:wah_group)
      @corporation.aktivitas.assign_user @user, at: 1.hour.ago
    end
    subject { @user.title }
    it "should return the user's name and his aktivitaetszahl" do
      @user.reload
      @user.name.blank?.should be_false
      @user.aktivitaetszahl.blank?.should be_false
      subject.should == @user.name + " " + @user.aktivitaetszahl
    end
  end
  
  describe ".find_by_title" do
    before do
      @user = create :user
      @corporation = create :corporation
      @corporation.assign_user @user
      create :user
      create :user
    end
    subject { User.find_by_title(@user.title) }
    specify "prelims" do
      @user.title.length.should > @user.name.length
    end
    it { should == @user }
  end

  describe "#bv" do
    before do
      @bv = create( :bv_group )
      @bv.assign_user @user, at: 1.hour.ago
    end
    subject { @user.reload.bv }
    it "should return the user's bv" do
      subject.should == @bv
    end
  end

  describe "#w_nummer" do
    subject { @user.w_nummer }
    describe "initially" do
      it { should be_nil }
    end
    describe "after setting it to a valid value" do
      before { @user.w_nummer = "W12345" }
      it { should == "W12345" }
    end
  end

  describe "#w_nummer=" do
    subject { @user.w_nummer = "W12345" }
    it "should set the w_nummer" do
      @user.w_nummer.should == nil
      subject
      @user.w_nummer.should == "W12345"
    end
    it "should persist" do
      @user.w_nummer.should == nil
      subject
      @user.reload.w_nummer.should == "W12345"
    end
  end

  describe ".find_by_w_nummer" do
    before do
      @user.w_nummer="W12345"
    end
    subject { User.find_by_w_nummer("W12345") }
    it "should deliver the right user" do
      should == @user
    end
  end

  describe "#aktivitaetszahl" do
    before do
      @corporationE = create( :corporation_with_status_groups, :token => "E" )
      @corporationH = create( :corporation_with_status_groups, :token => "H" )

      @first_membership_E = StatusGroupMembership.create( user: @user, group: @corporationE.status_groups.first )
      @first_membership_E.update_attributes(valid_from: "2006-12-01".to_datetime)
      @first_membership_H = StatusGroupMembership.create( user: @user, group: @corporationH.status_groups.first )
      @first_membership_H.update_attributes(valid_from: "2008-12-01".to_datetime)
      @first_membership_E.invalidate
      @second_membership_E = StatusGroupMembership.create( user: @user, group: @corporationE.status_groups.last )
      @second_membership_E.update_attributes(valid_from: "2013-12-01".to_datetime)
    end
    subject { @user.aktivitaetszahl }
    it "should return the composed aktivitaetszahl" do
      subject.should == "E06 H08"
    end
    it "should include only the right years (bug fix)" do
      subject.should_not == "H08 E13"
    end
    it "should not use the wrong order (bug fix)" do
      subject.should_not == "H08 E06"
    end
  end

  describe "#cached(:aktivitaetszahl)" do
    before do
      @corporationE = create( :corporation_with_status_groups, :token => "E" )
      @corporationH = create( :corporation_with_status_groups, :token => "H" )
      @corporationS = create( :corporation_with_status_groups, :token => "S" )

      @first_membership_E = StatusGroupMembership.create( user: @user, group: @corporationE.status_groups.first )
      @first_membership_E.update_attributes(valid_from: "2006-12-01".to_datetime)
      @first_membership_H = StatusGroupMembership.create( user: @user, group: @corporationH.status_groups.first )
      @first_membership_H.update_attributes(valid_from: "2008-12-01".to_datetime)
      @first_membership_E.invalidate
      @second_membership_E = StatusGroupMembership.create( user: @user, group: @corporationE.status_groups.last )
      @second_membership_E.update_attributes(valid_from: "2013-12-01".to_datetime)
    end
    subject { @user.cached(:aktivitaetszahl) }
    it "should return the composed cached aktivitaetszahl" do
      subject.should == "E06 H08"
    end
    it "should include only the right years (bug fix)" do
      subject.should_not == "H08 E13"
    end
    it "should not use the wrong order (bug fix)" do
      subject.should_not == "H08 E06"
    end
    describe "if currently 'E06 H08' and after adding S in 2014 it" do
      before do
        @user.cached(:aktivitaetszahl)
        first_membership_S = StatusGroupMembership.create( user: @user, group: @corporationS.status_groups.first )
        first_membership_S.update_attributes(valid_from: "2014-05-01".to_datetime)
        @user.reload
        sleep 0.7  # Otherwise it fails randomly.
      end
      it { should == "E06 H08 S14" }
    end
    describe "if currently 'E06 H08' and after leaving H it" do
      before do
        @user.cached(:aktivitaetszahl)
        @first_membership_H.invalidate( "2014-05-01".to_datetime )
        @user.reload
        sleep 0.7  # Otherwise it fails randomly.
      end
      it { should == "E06" }
    end
  end
  
  describe "#wingolfit?" do
    before { @user = create(:user) }
    subject { @user.wingolfit? }
    describe "for freshly created user" do
      it { should == false }
    end
    describe "for a user that has just an account" do
      before { @user = create(:user_with_account) }
      it { should == false }
    end
    describe "for a member of a Corporation status group (except guests)" do
      before do
        @corporation = create(:corporation_with_status_groups)
        @membership = @corporation.status_groups.first.assign_user @user
      end
      it { should == true}
      describe "when the member has died" do
        before { @user.set_date_of_death_if_unset "01.01.2006" }
        it { should == true }
      end
      describe "when the user terminated his membership" do
        before do
          @former_members = @corporation.child_groups.create
          @former_members.add_flag :former_members_parent
          @membership.promote_to @former_members, at: 2.minutes.ago
        end
        it { should == false }
      end
    end
    describe "for a guest of a corporation" do
      before do
        @corporation = create(:corporation_with_status_groups)
        @corporation.find_or_create_guests_parent_group.assign_user @user
      end
      it { should == false }
      describe "when the guest has died" do
        before { @user.set_date_of_death_if_unset "01.01.2006" }
        it { should == false }
      end
    end
    
  end  

  describe "#fill_in_template_profile_information" do

    before do
      @wingolfsblaetter_page = Page.create(title: "Wingolfsblätter")
      @abonnenten_group = @wingolfsblaetter_page.child_groups.create(name: "Abonnenten")
    end

    subject { @user.fill_in_template_profile_information }

    it "should not change the name of the user" do
      expect { subject }.to_not change { @user.name } 
    end
    it "should fill in certain empty profile fields" do
      subject
      @user.profile_fields.where(label: :personal_title).count.should == 1
      @user.profile_fields.where(label: :cognomen).count.should == 1
      @user.profile_fields.where(label: :home_address).count.should == 1
      @user.profile_fields.where(label: :work_or_study_address).count.should == 1
      @user.profile_fields.where(label: :phone).count.should == 1
      @user.profile_fields.where(label: :mobile).count.should == 1
      @user.profile_fields.where(label: :fax).count.should == 1
      @user.profile_fields.where(label: :homepage).count.should == 1
      @user.profile_fields.where(label: :academic_degree).count.should == 1
      @user.profile_fields.where(label: :professional_category).count.should == 1
      @user.profile_fields.where(label: :occupational_area).count.should == 1
      @user.profile_fields.where(label: :employment_status).count.should == 1
      @user.profile_fields.where(label: :bank_account).count.should == 1
      @user.profile_fields.where(label: :study).count.should == 1
    end
    it "should set the wingolfsblaetter_abo to true" do
      subject
      @user.wingolfsblaetter_abo.should == true
    end
  end

  describe "#wingolfsblaetter_abo" do

    before do
      @wingolfsblaetter_page = Page.create(title: "Wingolfsblätter")
      @abonnenten_group = @wingolfsblaetter_page.child_groups.create(name: "Abonnenten")
    end

    subject { @user.wingolfsblaetter_abo }

    describe "for the user being member of the @abonnenten_group" do
      before { @abonnenten_group.assign_user @user }
      it { should be_true }
    end
    describe "for the user not being member of the @abonnenten_group" do
      it { should be_false }
    end

    describe "#wingolfsblaetter_abo = true" do
      subject { @user.wingolfsblaetter_abo = true }
      it "should assign the user to the @abonnenten_group" do
        @abonnenten_group.direct_members.should_not include @user
        subject
        Group.find(@abonnenten_group.id).direct_members.should include @user
      end
    end
    describe "#wingolfsblaetter_abo = false" do
      before { @abonnenten_group.assign_user @user }
      subject { @user.reload.wingolfsblaetter_abo = false }
      it "should un-assign the user to the @abonnenten_group" do
        subject
        sleep 1.1
        Group.find(@abonnenten_group.id).direct_members.should_not include @user
      end
    end

  end
  
  describe "#correct_bv" do
    before do
      @bv0 = create(:bv_group, name: "BV 00 Unbekannt Verzogene", token: "BV 00")
      @bv1 = create(:bv_group, name: "BV 01 Berlin", token: "BV 01")
      @bv2 = create(:bv_group, name: "BV 45 Europe", token: "BV 45")
      @address1 = "Pariser Platz 1\n 10117 Berlin"
      @address2 = "44 Rue de Stalingrad, Grenoble, Frankreich"
      @address_field1 = @user.profile_fields.create(type: 'ProfileFieldTypes::Address', value: @address1).becomes ProfileFieldTypes::Address
      @address_field2 = @user.profile_fields.create(type: 'ProfileFieldTypes::Address', value: @address2).becomes ProfileFieldTypes::Address
      BvMapping.create(bv_name: "BV 01", plz: "10117")
    end
    subject { @user.correct_bv }
    
    describe "the user being philister" do
      before do
        @wah = create(:wah_group)
        @wah.philisterschaft.assign_user @user
      end
      specify "prelims" do
        @user.philister?.should == true
      end
      describe "for no address given" do
        before { @user.address_profile_fields.destroy_all }
        it "should return BV 00" do
          subject.try(:token).should == "BV 00"
        end
      end
      describe "for addresses given, but no address being selected as postal address" do
        it "should return the BV that matches the first given address" do
          subject.should == @address_field1.bv
          @address_field1.bv.should_not == nil
        end
      end
      describe "for a postal address being selected" do
        before { @address_field2.postal_address = true }
        it "should return the BV that matches the postal address" do
          subject.should == @address_field2.bv
          @address_field2.bv.should_not == nil
        end
      end
    end
    describe "the user being aktiver" do
      before do
        @wah = create(:wah_group)
        @wah.aktivitas.assign_user @user
      end
      specify "prelims" do
        @user.aktiver?.should == true
      end
      it { should == nil }
    end
  end
  
  describe "#adapt_bv_to_postal_address" do
    before do
      @bv0 = create(:bv_group, name: "BV 00 Unbekannt Verzogene", token: "BV 00")
      @bv1 = create(:bv_group, name: "BV 01 Berlin", token: "BV 01")
      @bv2 = create(:bv_group, name: "BV 45 Europe", token: "BV 45")
      @address1 = "Pariser Platz 1\n 10117 Berlin"
      @address2 = "44 Rue de Stalingrad, Grenoble, Frankreich"
      @address_field1 = @user.profile_fields.create(type: 'ProfileFieldTypes::Address', value: @address1).becomes ProfileFieldTypes::Address
      @address_field2 = @user.profile_fields.create(type: 'ProfileFieldTypes::Address', value: @address2).becomes ProfileFieldTypes::Address
      BvMapping.create(bv_name: "BV 01", plz: "10117")
    end
    subject { @user.adapt_bv_to_postal_address }
    
    specify "prelims" do
      Bv.by_address(@address1).should == @bv1
      Bv.by_address(@address2).should == @bv2
    end
    describe "for the user being philister" do
      before do
        @wah = create(:wah_group)
        @wah.philisterschaft.assign_user @user
      end
      specify "prelims" do
        @user.philister?.should == true
      end
      describe "for no bv membership existing" do
        describe "if no address is selected as postal address" do
          it "should assign the user to the BV the matches the first entered address" do
            subject
            @user.bv.should == @bv1
            @address_field1.bv.should == @bv1
          end
          it "should return the new membership" do
            subject.should == UserGroupMembership.find_by_user_and_group(@user, @bv1)
          end
        end
      end
      describe "for an address being selected as postal address that already matches the current BV" do
        before do
          @bv1.assign_user @user
          @address_field1.wingolfspost = true
        end
        it "should keep the memberships as they are" do
          subject
          @user.bv.should == @bv1
          
          # a double dag link would indicate that the membership had been created twice.
          @user.bv_membership.count.should == 1
        end
        it "should return the kept membership" do
          old_membership = @user.reload.bv_membership
          subject.should == old_membership
        end
      end
      describe "for an address being selected as postal address that matches a new BV" do
        before do
          @membership1 = @bv1.assign_user @user, at: 1.year.ago
          @address_field2.wingolfspost = true
        end
        specify "prelims" do
          @address_field2.bv.should == @bv2
          @user.postal_address_field.should == @address_field2
        end
        it "should assign the user to the new BV" do
          subject
          sleep 1.1  # because of the validity range time comparison
          @user.reload.bv.should == @bv2
        end
        it "should end the current BV membership" do
          subject
          @membership1.reload.valid_to.should_not == nil
        end
        it "should return the new membership" do
          new_membership = subject
          membership_in_bv2 = UserGroupMembership.with_invalid.find_by_user_and_group(@user, @bv2)
          membership_in_bv2.should_not == nil
          new_membership.should == membership_in_bv2
        end
      end
      describe "for an address being selected that does not match a BV" do
        before do
          @membership2 = @bv2.assign_user @user, at: 1.year.ago
          BvMapping.destroy_all
          @address_field1.wingolfspost = true
        end
        specify "prelims" do
          Bv.by_address(@address1).should == nil
          @address_field1.bv.should == nil
        end
        it "should continue the old BV membership" do
          subject
          @user.bv.should == @bv2
          @membership2.reload.valid_to.should == nil
        end
        it { should == @membership2 }
      end
      describe "for a user without address" do
        before do
          @user.profile_fields.destroy_all
          @user.reload
        end
        it "should assign the user to BV 00" do
          subject
          @user.bv.token.should == "BV 00"
        end
        it "should return the new membership" do
          subject.should == UserGroupMembership.find_by_user_and_group(@user, @bv0)
        end
      end
      describe "if the bv could not be determined by plz" do
        before do
          BvMapping.destroy_all
        end
        it "should assign no bv" do
          subject
          @user.bv.should == nil
        end
        it { should == nil }
      end
      describe "for the user having multiple bv memberships" do
        before do
          @membership0 = @bv0.assign_user @user
          @membership1 = @bv1.assign_user @user
          @address_field2.wingolfspost = true  # the correct bv is @bv2.
        end
        it "should remove all old memberships" do
          subject
          sleep 1.1  # because of the time comparison of valid_from/valid_to.
          UserGroupMembership.find_by_user_and_group(@user, @bv0).should == nil
          UserGroupMembership.find_by_user_and_group(@user, @bv1).should == nil
        end
        specify "the user should only have ONE bv membership, now" do
          subject
          sleep 1.1  # because of the time comparison of valid_from/valid_to.
          (@user.groups(true) & Bv.all).count.should == 1
        end
        it "should assign the user to the correct bv" do
          subject
          sleep 1.1  # because of the time comparison of valid_from/valid_to.
          @user.reload.bv.should == @bv2
        end
        it "should return the new membership" do
          subject.should == UserGroupMembership.find_by_user_and_group(@user, @bv2)
        end
      end
    end
    describe "for the user being aktiver" do
      before do
        @wah = create(:wah_group)
        @wah.aktivitas.assign_user @user
      end
      specify "prelims" do
        @user.aktiver?.should == true
      end
      it "should not assign a bv" do
        subject
        sleep 1.1
        @user.reload.bv.should == nil
      end
      it { should == nil }      
    end
  end
  
  
  describe "#mark_as_deceased" do
    before { @date = 1.day.ago }
    subject { @user.mark_as_deceased(at: @date) }
    
    describe "the user being member of a bv" do
      before do
        @bv = create(:bv_group)
        @bv_membership = @bv.assign_user @user
      end
      it "should end the bv membership" do
        @bv_membership.valid_to.should == nil
        subject
        @bv_membership.reload.valid_to.should_not == nil
      end
    end
    describe "the user being member of corporations" do
      before do
        @corporation_a = create(:wah_group)
        @corporation_b = create(:wah_group)
        @corporation_a.status_group("Philister").assign_user @user, at: 1.year.ago
        @corporation_b.status_group("Philister").assign_user @user, at: 1.year.ago
      end
      it "should set the status to deceased in these corporations" do
        subject
        @user.reload.current_status_group_in(@corporation_a).should == @corporation_a.deceased
        @user.current_status_group_in(@corporation_b).should == @corporation_b.deceased
      end
    end
    describe "the user being a former member of a corporation" do
      before do
        @corporation_a = create(:wah_group)
        @membership = @corporation_a.assign_user @user, at: 2.years.ago
        @membership.promote_to @corporation_a.status_group("Schlicht Ausgetretene"), at: 1.year.ago
      end
      it "should not set the status to deceased in this corporation" do
        # Ein Wingolfit bleibt auch nach seinem Tode ein Wingolfit. Er behält seine
        # Aktivitätszahl. Ein Ausgetretener verliert sie.
        #
        subject
        @user.reload.current_status_group_in(@corporation_a).should == @corporation_a.status_group("Schlicht Ausgetretene")
        @user.current_status_group_in(@corporation_a).should_not == @corporation_a.deceased
        @user.current_corporations.should_not include @corporation_a
      end
    end
    describe "the user having a wingolfsblaetter_abo" do
      before { @user.wingolfsblaetter_abo = true }
      it "should end the wingolfsblaetter_abo" do
        @user.reload
        subject
        @user.reload.wingolfsblaetter_abo.should == false
      end
    end
    describe "the user having an account" do
      before { @account = @user.activate_account }
      it "should destroy the account" do
        @user.account.should be_kind_of UserAccount
        subject
        @user.reload.account.should == nil
      end
    end
    
  end
  
end
