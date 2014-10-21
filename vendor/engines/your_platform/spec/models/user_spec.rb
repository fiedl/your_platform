# -*- coding: utf-8 -*-
require 'spec_helper'

describe User do

  before do 
    @user = create( :user )
    @user.save
  end

  subject { @user }

  # Validation
  # ==========================================================================================

  it { should be_valid }


  # Basic Properties
  # ==========================================================================================

  describe "accessible attributes" do
    subject { @user }
    [ :first_name, :last_name, :alias, :email, :create_account, :female, :add_to_group ].each do |attr|
      it { should respond_to( attr ) }
      it { should respond_to( "#{attr}=".to_sym ) }
    end
  end

  describe "#name" do
    subject { @user.name }
    it { should == "#{@user.first_name} #{@user.last_name}" }
  end

  describe "#capitalize_name" do
    [ { first_name: "john", last_name: "doe", 
        capitalized_first_name: "John", capitalized_last_name: "Doe" },
      { first_name: "Bruno", last_name: "de Silva", 
        capitalized_first_name: "Bruno", capitalized_last_name: "de Silva" },
      { first_name: "Klaus-Dieter", last_name: "Kunz", 
        capitalized_first_name: "Klaus-Dieter", capitalized_last_name: "Kunz" } ].each do |name_to_test|
      describe "for '#{name_to_test[ :capitalized_last_name ]}'" do
        before do
          @user.first_name = name_to_test[ :first_name ]
          @user.last_name = name_to_test[ :last_name ]
          @user.capitalize_name
          @user.save
        end
        it "should capitalize the first_name and last_name" do
          @user.first_name.should == name_to_test[ :capitalized_first_name ]
          @user.last_name.should == name_to_test[ :capitalized_last_name ]
          @user.name.should == name_to_test[ :capitalized_first_name ] + " " + 
            name_to_test[ :capitalized_last_name ]
        end
      end
    end
  end

  describe "#title" do
    subject { @user.title }
    # the title is likely to be overridden in the main application. Therefore, here are
    # just a few vague tests.
    it { should include( @user.last_name ) }
    it { should_not be_empty }
  end

  describe "#gender" do
    it "should return :female if the user is female" do
      @user.female = true
      @user.gender.should == :female
    end
    it "should return :male if the user is not female" do
      @user.female = false
      @user.gender.should == :male
    end
  end

  describe "#gender=" do
    it "should set :female to true if the gender is female" do
      @user.gender = :female
      @user.female?.should == true
    end
    it "should set :female to false if the gender is male" do
      @user.gender = :male
      @user.female?.should == false
    end
    it "should set :female to false if the gender is something else" do
      @user.gender = :something_else
      @user.female?.should == false
    end
  end


  describe "#date_of_birth" do
    subject { @user.date_of_birth }
    describe "before setting a date of birth" do
      it { should == nil }
    end
    describe "after setting a date of birth" do
      before { @user.date_of_birth = 24.years.ago.to_date }
      it { should be_kind_of Date }
      it "should persist" do
        @user.save
        @reloaded_user = User.find(@user.id)
        @reloaded_user.date_of_birth.should == @user.date_of_birth
      end
      it "should be stored inside a ProfileField" do
        @user.save
        @profile_field = @user.profile_fields.where( label: 'date_of_birth' ).first
        @profile_field.value.to_date.should == @user.date_of_birth
      end
    end
    it "should be autosaved" do
      @user = create(:user)
      @user.date_of_birth = "2001-01-01"
      @user.save
      User.find(@user.id).date_of_birth.should == "2001-01-01".to_date
    end
    describe "after a former date of birth has been saved" do
      before do
        @user.date_of_birth = 27.years.ago.to_date
        @user.save
      end
      specify "prelim: the date of birth should be saved before" do
        @user.reload
        @user.date_of_birth.should == 27.years.ago.to_date
      end
      specify "a changed date of birth should be autosaved (bug fix)" do
        @user.reload
        @user.date_of_birth = "2001-01-01".to_date
        @user.save
        User.find(@user.id).date_of_birth.should == "2001-01-01".to_date
      end
    end
  end

  describe "#date_of_birth=" do
    before { @date_of_birth = 24.years.ago.to_date }
    subject { @user.date_of_birth = @date_of_birth; @user.save }
    it "should set the date of birth" do
      @user.date_of_birth.should == nil
      subject
      @user.date_of_birth.should == @date_of_birth
    end
  end
  
  describe "#localized_date_of_birth" do
    subject { @user.localized_date_of_birth }
    describe "for a given date of birth" do
      before do
        @date_of_birth = "1987-01-11".to_date
        @user.date_of_birth = @date_of_birth
      end
      it { should == I18n.localize(@date_of_birth) }
      it "should return the correctly localized date" do
        I18n.locale.should == :de
        subject.should be_in ["11.01.1987", "11.1.1987"]
      end
    end
    describe "for the user not having a date of birth in the database" do
      it "should return nil" do
        @user.date_of_birth.should == nil
        subject.should == nil
      end
    end
  end
  describe "#localized_date_of_birth=" do
    subject { @user.localized_date_of_birth = @given_string; @user.save }
    describe "for setting a valid date of birth" do
      before { @given_string = "11.01.1987" }
      it "should set the date correctly" do
        @user.date_of_birth.should_not == "1987-01-11".to_date
        subject
        @user.date_of_birth.should == "1987-01-11".to_date
      end
    end
    describe "for setting an empty string" do
      before do
        @user.date_of_birth = 24.years.ago.to_date
        @given_string = "" 
      end
      it "should set the date of birth to nil" do
        subject
        @user.date_of_birth.should == nil
      end
    end
    describe "for setting an invalid date string" do
      before do
        @user.date_of_birth = 24.years.ago.to_date
        @given_string = "foo"
      end
      it "should set the date of birth to nil" do
        subject
        @user.date_of_birth.should == nil
      end
    end
  end
  
  describe "#date_of_birth_profile_field" do
    subject { @user.date_of_birth_profile_field }
    describe "for no date of birth field created" do
      it { should == nil }
    end
    describe "for an existing date of birth" do
      before { @user.date_of_birth = "1900-01-01".to_date }
      it { should be_kind_of ProfileField }
      its(:type) { should == "ProfileFieldTypes::Date" }
    end
    it "should be autosaved" do
      @field = @user.build_date_of_birth_profile_field
      @field.value = "2001-01-01"
      @user.save
      @user = User.find(@user.id)
      subject.value.to_date.should == "2001-01-01".to_date
    end
  end
  describe "#find_or_build_date_of_birth_profile_field" do
    subject { @user.find_or_build_date_of_birth_profile_field }
    describe "for no date of birth field created" do
      it { should be_kind_of ProfileField }
      its(:type) { should == "ProfileFieldTypes::Date" }
      its(:new_record?) { should == true }
    end
    describe "for an existing date of birth" do
      before { @user.date_of_birth = "1900-01-01".to_date }
      it { should be_kind_of ProfileField }
      its(:type) { should == "ProfileFieldTypes::Date" }
    end
    describe "for a date of birth existing in the database" do
      before do
        @user.date_of_birth = "1900-01-01".to_date
        @user.save
        @user = User.find(@user.id)
      end
      it { should be_kind_of ProfileField }
      its(:type) { should == "ProfileFieldTypes::Date" }
      its('value.to_date') { should == "1900-01-01".to_date }
      its(:new_record?) { should == false }
    end
  end
  describe "#find_or_create_date_of_birth_profile_field" do
    subject { @user.find_or_create_date_of_birth_profile_field }
    describe "for no date of birth field existing" do
      it { should be_kind_of ProfileField }
      its(:type) { should == "ProfileFieldTypes::Date" }
      its(:new_record?) { should == false }
      its(:id) { should be_kind_of Integer }
     end
     describe "for a date of birth existing in the database" do
       before do
         @user.date_of_birth = "1900-01-01".to_date
         @user.save
         @user = User.find(@user.id)
       end
       it { should be_kind_of ProfileField }
       its(:type) { should == "ProfileFieldTypes::Date" }
       its('value.to_date') { should == "1900-01-01".to_date }
       its(:new_record?) { should == false }
     end
  end

  describe "postal address: " do
    before do
      @other_field = ProfileFieldTypes::Address.create(label: "My Work", value: "Some Other Address")
      @profile_field = ProfileFieldTypes::Address.create(label: "My Home", value: "Some Address")
      @user.profile_fields << @other_field 
      @user.profile_fields << @profile_field
    end
    describe "#postal_address_field" do
      subject { @user.postal_address_field }
      describe "for no primary postal address being set" do
        it "should return nil" do
          subject.should == nil 
        end
      end
      describe "for a primary postal address being set" do
        before { @profile_field.postal_address = true }
        it "should return the address field" do
          subject.should == @profile_field
        end
      end
    end
    describe "#postal_address" do
      subject { @user.postal_address }
      describe "for no primary postal address being set" do
        it "should return the first address of the user" do
          subject.should == @other_field.value
        end
      end
      describe "for a primary postal address being set" do
        before { @profile_field.postal_address = true }
        it "should return the address field's value" do
          subject.should == "Some Address" 
        end
      end
    end
    describe "#postal_address_with_name_surrounding" do
      subject { @user.postal_address_with_name_surrounding }
      before do
        @name_surrounding = @user.profile_fields.create(type: 'ProfileFieldTypes::NameSurrounding').becomes(ProfileFieldTypes::NameSurrounding)
        @name_surrounding.name_prefix = "Dr."
        @name_surrounding.name_suffix = "M.Sc."
        @name_surrounding.text_above_name = "Herrn"
        @name_surrounding.text_below_name = "Bankdirektor"
        @name_surrounding.save
        @user.save
      end
      specify "prelims" do
        @user.name_surrounding_profile_field.should == @name_surrounding
        @user.name_surrounding_profile_field.text_above_name.should == "Herrn"
        @user.text_above_name.should == "Herrn"
      end
      it { should == 
        "Herrn\n" +
        "Dr. #{@user.first_name} #{@user.last_name} M.Sc.\n" + 
        "Bankdirektor\n" +
        @user.postal_address
      }
      describe "when no name surroundings are given" do
        before { @name_surrounding.destroy }
        it { should == "#{@user.name}\n#{@user.postal_address}" }
      end
      describe "when the user has the same personal title as given in the name prefix" do
        before do
          @user.profile_fields.create(type: 'ProfileFieldTypes::General', label: 'personal_title', value: "Dr.")
          @user.save
        end
        it "should not print it twice" do
          subject.should == 
          "Herrn\n" +
          "Dr. #{@user.first_name} #{@user.last_name} M.Sc.\n" + 
          "Bankdirektor\n" +
          @user.postal_address
        end
      end
      describe "when there is no text below the name" do
        before { @name_surrounding.update_attributes(text_below_name: "") }
        it "should leave no blank line" do
          subject.should == 
          "Herrn\n" +
          "Dr. #{@user.first_name} #{@user.last_name} M.Sc.\n" + 
          @user.postal_address
        end
      end
      describe "when there is no text above the name" do
        before { @name_surrounding.update_attributes(text_above_name: "") }
        it "should not begin with a blnak line" do
          subject.should == 
          "Dr. #{@user.first_name} #{@user.last_name} M.Sc.\n" + 
          "Bankdirektor\n" +
          @user.postal_address
        end
      end
      describe "when there is neither prefix nor personal title" do
        before { @name_surrounding.update_attributes(name_prefix: '') }
        it "should set no spaces before the name" do
          subject.should == 
          "Herrn\n" +
          "#{@user.first_name} #{@user.last_name} M.Sc.\n" + 
          "Bankdirektor\n" +
          @user.postal_address
        end
      end
      describe "when there is no name suffix" do
        before { @name_surrounding.update_attributes(name_suffix: '') }
        it "should set no spaces after the name" do
          subject.should == 
          "Herrn\n" +
          "Dr. #{@user.first_name} #{@user.last_name}\n" + 
          "Bankdirektor\n" +
          @user.postal_address
        end
      end
    end
  end
  
  describe "#phone_profile_fields" do
    subject { @user.phone_profile_fields }
    before do
      @phone_field = @user.profile_fields.create(label: 'Phone', type: 'ProfileFieldTypes::Phone', value: '123456').becomes(ProfileFieldTypes::Phone)
      @fax_field = @user.profile_fields.create(label: 'Fax', type: 'ProfileFieldTypes::Phone', value: '123457').becomes(ProfileFieldTypes::Phone)
      @mobile_field = @user.profile_fields.create(label: 'Mobile', type: 'ProfileFieldTypes::Phone', value: '01234').becomes(ProfileFieldTypes::Phone)
      @user.reload
    end
    it { should include @phone_field }
    it { should_not include @fax_field }
    it { should include @mobile_field }
  end

  
  # Associated Objects
  # ==========================================================================================

  # Alias
  # ------------------------------------------------------------------------------------------

  describe "#alias" do
    describe "for an already created user" do
      subject { @user.alias }
      it { should be_kind_of( UserAlias ) }
      it { should_not be_empty }
    end
    describe "for a newly built user without alias being set" do
      before do
        @user = User.new(first_name: "James", last_name: "Doe", email: "doe@example.com")
      end
      subject { @user.alias }
      it { should == nil }
    end
  end
  
  describe "#alias=" do
    it "should set the alias attribute" do
      @user.alias = "New Alias"
      @user.alias.should == "New Alias"
    end
  end
  
  describe "#generate_alias" do
    before do
      @user = build(:user, first_name: "Tamara", last_name: "Sweet")
    end
    subject { @user.generate_alias }
    it "should generate the alias" do
      subject.should be_kind_of UserAlias
      subject.should == "sweet"
    end
    it "should not set the alias of the user" do
      subject
      @user.alias.should_not == "sweet"
    end
  end
  
  describe "#generate_alias!" do
    before do
      @user = build(:user, first_name: "Tamara", last_name: "Sweet")
    end
    subject { @user.generate_alias! }
    it "should generate the alias" do
      subject.should be_kind_of UserAlias
      subject.should == "sweet"
    end
    it "should set the alias of the user" do
      subject
      @user.alias.should == "sweet"
    end
  end
  
  specify "an alias should be generated on user creation" do
    @user = User.create(first_name: "James", last_name: "Doe", email: "doe@example.com")
    @user.alias.should be_kind_of UserAlias
    @user.alias.should == "doe"
  end
  
  
  # User Account
  # ------------------------------------------------------------------------------------------

  context "for a user with account" do
    before { @user_with_account = create( :user_with_account ) }
    subject { @user_with_account }

    describe "#has_account?" do
      subject { @user_with_account.has_account? }
      it { should == true }
    end

    describe "#activate_account" do
      it "should keep the existing account" do
        @existing_account = @user_with_account.account
        @user_with_account.activate_account
        @user_with_account.account.should == @existing_account
      end
    end

    describe "#deactivate_account" do
      it "should destroy the existing account" do
        @user_with_account.account.should_not be_nil
        @user_with_account.deactivate_account
        @user_with_account.account.should be_nil
        @user_with_account.has_account?.should == false
      end
    end

    specify "the new user should have an initial password" do
      # This is to avoid the bug of welcome emails with a blank password.
      subject.account.password.should_not be_empty
    end
  end

  context "for a user without account" do
    before { @user_without_account = create( :user, :create_account => false ) }

    describe "#has_account?" do
      subject { @user_without_account.has_account? }
      it { should == false }
    end

    describe "#activate_account" do
      it "should create an account" do
        @user_without_account.account.should == nil
        @user_without_account.activate_account
        @user_without_account.account.should be_kind_of( UserAccount )
        @user_without_account.should_not be_nil
      end
    end

    describe "#deactivate_account" do
      it "should raise an error, since no account exists" do
        expect { @user_without_account.deactivate_account }.to raise_error
      end
    end
  end

  describe "#create_account attribute" do
    describe "#create_account == true" do
      it "should cause the user to be created with account" do
        create( :user, create_account: true ).account.should_not be_nil
      end
    end
    describe "#create_account == false" do
      it "should cause the user to be created without account" do
        create( :user, create_account: false ).account.should be_nil
      end
    end
    describe "#create_account == 0" do
      it "should cause the user to be created without account" do
        create( :user, create_account: 0 ).account.should be_nil
      end
    end
    describe "#create_account == 1" do
      it "should cause the user to be created with account" do
        create( :user, create_account: 1 ).account.should_not be_nil
      end
    end
    describe "#create_account == '0'" do # for HTML forms
      it "should cause the user to be created without account" do
        create( :user, create_account: "0" ).account.should be_nil
      end
    end
    describe "#create_account == '1'" do # for HTML forms
      it "should cause the user to be created with account" do
        create( :user, create_account: "1" ).account.should_not be_nil
      end
    end
    describe "#create_account == ''" do
      it "should cause the user to be created without account" do
        create( :user, create_account: "" ).account.should be_nil
      end
    end
  end


  # Groups
  # ------------------------------------------------------------------------------------------

  describe "#groups" do
    before do
      @group = create( :group )
      @everyone_group = Group.everyone
      @group.parent_groups << @everyone_group
      @user.save
      @user.parent_groups << @group
      @user.reload
    end
    subject { @user.groups }
    it "should include the groups the user is a direct member of" do
      subject.should include( @group )
    end
    it "should include the groups the user is an indirect member of" do
      subject.should include( Group.everyone )
    end
    it "should return all ancestor groups" do
      subject.should == @user.ancestor_groups
    end
  end

  describe "#add_to_group attribute" do
    before do
      @group = create( :group )
    end
    describe "#add_to_group == nil" do
      subject { create( :user, :add_to_group => nil ) }
      it "should not add the user to a group during creation" do
        subject.parent_groups.should_not include( @group )
      end
    end
    describe "#add_to_group == some_group" do
      subject { create( :user, :add_to_group => @group ) }
      it "should add the user to the group during creation" do
        subject.parent_groups.should include( @group )
      end
    end
    describe "#add_to_group == some_group_id" do
      subject { create( :user, :add_to_group => @group.id ) }
      it "should add the user to the group during creation" do
        subject.parent_groups.should include( @group )
      end
    end
  end


  # Corporations
  # ------------------------------------------------------------------------------------------

  describe "#corporations" do
    before do
      @corporation = create( :corporation )
      @subgroup = create( :group ); @subgroup.parent_groups << @corporation
      @user.save
      @user.parent_groups << @subgroup
      @user.reload
    end
    subject { @user.corporations }
    it "should return an array of the user's corporations" do
      subject.should == [ @corporation ]
    end
    it "should return an array of Corporation-type objects" do
      subject.should be_kind_of Array
      subject.first.should be_kind_of Corporation
    end
  end

  describe "#cached(:corporations)" do
    before do
      @corporationE = create( :corporation_with_status_groups, :token => "E" )
      @corporationS = create( :corporation_with_status_groups, :token => "S" )
      @corporationH = create( :corporation_with_status_groups, :token => "H" )
      @subgroup = create( :group );
      @subgroup.parent_groups << @corporationE
      @user.save
      @first_membership_E = StatusGroupMembership.create( user: @user, group: @corporationE.status_groups.first )
      @user.parent_groups << @subgroup
      @user.reload
    end
    subject { @user.cached(:corporations) }
    it "should return an array of the user's corporations" do
      should == @user.corporations
    end
    context "when user entered corporation S" do
      before do
        @user.cached(:corporations)
        wait_for_cache
        
        first_membership_S = StatusGroupMembership.create( user: @user, group: @corporationS.status_groups.first )
        first_membership_S.update_attributes(valid_from: "2010-05-01".to_datetime)
        @user.reload
      end
      it { should == @user.corporations }
    end
    context "when user entered corporation H as guest" do
      before do
        @user.cached(:corporations)
        wait_for_cache

        first_membership_H = StatusGroupMembership.create( user: @user, group: @corporationH.guests_parent )
        first_membership_H.update_attributes(valid_from: "2010-05-01".to_datetime)
        @user.reload
      end
      it { should == @user.corporations }
    end
    context "when user left corporation E" do
      before do
        @user.cached(:corporations)
        former_group = @corporationE.child_groups.create
        former_group.add_flag :former_members_parent
        second_membership_E = StatusGroupMembership.create( user: @user, group: former_group )
        second_membership_E.update_attributes(valid_from: "2014-05-01".to_datetime)
        @first_membership_E.update_attributes(valid_to: "2014-05-01".to_datetime)
        @user.reload
      end
      it { should == @user.corporations }
    end
  end

  describe "#current_corporations" do
    before do
      @corporationE = create( :corporation_with_status_groups, :token => "E" )
      @corporationS = create( :corporation_with_status_groups, :token => "S" )
      @corporationH = create( :corporation_with_status_groups, :token => "H" )
      @subgroup = create( :group );
      @subgroup.parent_groups << @corporationE
      @user.save
      @first_membership_E = StatusGroupMembership.create( user: @user, group: @corporationE.status_groups.first )
      @user.parent_groups << @subgroup
      @user.reload
    end
    subject { @user.current_corporations }
    it "should return an array of the user's corporations" do
      should == @user.corporations
      should include @corporationE
      should_not include @corporationS, @corporationH
    end
    context "when user entered corporation S" do
      before do
        first_membership_S = StatusGroupMembership.create( user: @user, group: @corporationS.status_groups.first )
        first_membership_S.update_attributes(valid_from: "2010-05-01".to_datetime)
        @user.reload
      end
      it { should == [ @corporationE, @corporationS ] }
    end
    context "when user entered corporation H as guest" do
      before do
        first_membership_H = StatusGroupMembership.create( user: @user, group: @corporationH.guests_parent )
        first_membership_H.update_attributes(valid_from: "2010-05-01".to_datetime)
        @user.reload
      end
      it { should == [ @corporationE ] }
    end
    context "when user left corporation E" do
      before do
        former_group = @corporationE.child_groups.create
        former_group.add_flag :former_members_parent
        second_membership_E = StatusGroupMembership.create( user: @user, group: former_group )
        second_membership_E.update_attributes(valid_from: "2014-05-01".to_datetime)
        @first_membership_E.update_attributes(valid_to: "2014-05-01".to_datetime)
        @user.reload
      end
      it { should be_empty }
    end
    context "when joining an event of a corporation" do
      before do
        @event = @corporationH.child_events.create
        @event.attendees << @user
        @user.reload
      end
      it { should_not include @corporationH }
    end
  end

  describe "#cached(:current_corporations)" do
    before do
      @corporationE = create( :corporation_with_status_groups, :token => "E" )
      @corporationS = create( :corporation_with_status_groups, :token => "S" )
      @corporationH = create( :corporation_with_status_groups, :token => "H" )
      @subgroup = create( :group );
      @subgroup.parent_groups << @corporationE
      @user.save
      @first_membership_E = StatusGroupMembership.create( user: @user, group: @corporationE.status_groups.first )
      @user.parent_groups << @subgroup
      @user.reload
    end
    subject { @user.cached(:current_corporations) }
    it "should return an array of the user's corporations" do
      should == @user.corporations
    end
    context "when user entered corporation S" do
      before do
        @user.cached(:current_corporations)
        wait_for_cache

        first_membership_S = StatusGroupMembership.create( user: @user, group: @corporationS.status_groups.first )
        first_membership_S.update_attributes(valid_from: "2010-05-01".to_datetime)
        @user.reload
      end
      it { should == [ @corporationE, @corporationS ] }
    end
    context "when user entered corporation H as guest" do
      before do
        @user.cached(:current_corporations)
        first_membership_H = StatusGroupMembership.create( user: @user, group: @corporationH.guests_parent )
        first_membership_H.update_attributes(valid_from: "2010-05-01".to_datetime)
        @user.reload
      end
      it { should == [ @corporationE ] }
    end
    context "when user left corporation E" do
      before do
        @user.cached(:current_corporations)
        wait_for_cache

        former_group = @corporationE.child_groups.create
        former_group.add_flag :former_members_parent
        second_membership_E = StatusGroupMembership.create( user: @user, group: former_group )
        second_membership_E.update_attributes(valid_from: "2014-05-01".to_datetime)
        @first_membership_E.update_attributes(valid_to: "2014-05-01".to_datetime)
        @user.reload
      end
      it { should be_empty }
   end
  end

  describe "#first_corporation" do
    before do
      @corporation1 = create( :corporation_with_status_groups )
      @corporation2 = create( :corporation_with_status_groups )
      @corporation1.status_groups.first.assign_user @user, at: 1.year.ago
      @corporation2.status_groups.first.assign_user @user, at: 3.months.ago
      @user.reload
    end
    subject { @user.first_corporation }
    it "should return the user's first corporation" do
      subject.should == @corporation1
    end
  end

  describe "#my_groups_in_first_corporation" do
    before do
      @corporation1 = create :corporation_with_status_groups
      @corporation2 = create :corporation_with_status_groups
      @corporation1.status_groups.first.assign_user @user
      @corporation1.status_groups.last.assign_user @user
      @corporation2.status_groups.first.assign_user @user
      @corporation1.admins << @user
      @user.reload
    end
    subject { @user.my_groups_in_first_corporation }
    it "should return the non special groups of user's first corporation" do
      subject.should == [ @corporation1.status_groups.first, @corporation1.status_groups.last ]
    end
  end

  describe "#last_group_in_first_corporation" do
    before do
      @corporation1 = create :corporation_with_status_groups
      @corporation2 = create :corporation_with_status_groups
      @corporation1.status_groups.first.assign_user @user, at: 10.months.ago
      @corporation1.status_groups.last.assign_user @user, at: 2.months.ago
      @corporation2.status_groups.first.assign_user @user, at: 1.month.ago
      @corporation1.admins << @user
      @user.reload
    end
    subject { @user.cached(:last_group_in_first_corporation) }
    it "should return the last non special group of user's first corporation" do
      subject.should == @corporation1.status_groups.last
      subject.should_not == @corporation1.admins_parent
    end
  end
  
  # Status Groups
  # ------------------------------------------------------------------------------------------

  describe "#status_groups" do
    before do
      @corporation = create( :corporation_with_status_groups )
      @status_group = @corporation.status_groups.first
      @status_group.assign_user @user
      @another_group = create( :group )
      @another_group.assign_user @user
    end
    subject { @user.status_groups }

    it "should include the status groups of the user" do
      subject.should include @status_group
    end
    it "should not include the non-status groups of the user" do
      subject.should_not include @another_group
    end
  end
  
  describe "#current_status_membership_in(corporation)" do
    before do
      @corporation = create( :corporation_with_status_groups )
      @status_group = @corporation.status_groups.first
      @status_group.assign_user @user
      @status_group_membership = StatusGroupMembership.find_by_user_and_group(@user, @status_group)
    end
    subject { @user.current_status_membership_in(@corporation) }
    
    it "should return the correct membership" do
      subject.should == @status_group_membership
    end
  end

  
  # Memberships
  # ------------------------------------------------------------------------------------------

  describe "#memberships" do
    before do
      @group = create( :group )
      @group.child_users << @user
      @membership = UserGroupMembership.find_by( user: @user, group: @group )
    end
    subject { @user.memberships }
    it "should return an array of the user's memberships" do
      subject.should == [ @membership ]
    end
    it "should be the same as UserGroupMembership.find_all_by_user" do
      subject.should == UserGroupMembership.find_all_by_user( @user )
    end
    it "should allow to chain other ActiveRelation scopes, like `only_valid`" do
      subject.only_valid.should == [ @membership ]
    end
  end


  # Relationships
  # ------------------------------------------------------------------------------------------

  describe "#relationships" do
    before do
      @other_user = create( :user )
      @relationship = create( :relationship, who: @user, of: @other_user )
    end
    subject { @user.relationships }
    it "should return the relationships of the user" do
      subject.should == [ @relationship ]
    end
  end


  # Workflows
  # ------------------------------------------------------------------------------------------

  describe "#workflows" do
    before do 
      @group = create( :group )      
      @workflow = create( :workflow ); @workflow.parent_groups << @group
      @user.save
      @user.parent_groups << @group
      @user.reload
    end
    subject { @user.workflows }
    it "should return an array of all workflows of all groups of the user" do
      subject.should == [ @workflow ]
    end
  end


  # Events
  # ------------------------------------------------------------------------------------------

  describe "#upcoming_events" do
    subject { @user.upcoming_events }
    describe "(timing)" do
      before do
        @group1 = @user.parent_groups.create
        @group2 = @group1.parent_groups.create
        @upcoming_events = [ @group1.child_events.create( start_at: 5.hours.from_now ),
                             @group2.child_events.create( start_at: 6.hours.from_now ) ]
        @recent_events = [ @group1.child_events.create( start_at: 5.hours.ago ) ]
        @unrelated_events = [ Event.create( start_at: 4.hours.from_now ) ]
      end
      it { should include *@upcoming_events }
      it { should_not include *@recent_events }
      it { should_not include *@unrelated_events }
      it "should return the upcoming events in ascending order" do
        subject.first.start_at.should < subject.last.start_at
      end
    end
    describe "(direct/indirect)" do
      # group_a 
      #   |----- event_0             <<===
      #   |----- group_b
      #   |        |------ event_1   <<===
      #   |        |------ user    
      #   |
      #   |----- group_c
      #            |------ event_2
      before do
        @group_a = create( :group )
        @event_0 = @group_a.child_events.create( start_at: 5.hours.from_now )
        @group_b = @group_a.child_groups.create
        @group_b.child_users << @user
        @event_1 = @group_b.child_events.create( start_at: 5.hours.from_now )
        @group_c = @group_a.child_groups.create
        @event_2 = @group_c.child_events.create( start_at: 5.hours.from_now )
        @user.reload
      end
      it "should list direct events of the user's groups" do # "<<===" above
        @user.ancestor_groups.should include @group_a, @group_b
        subject.should include @event_0, @event_1
      end
      it "should not list in-direct events" do
        # otherwise all users will see all events, since everyone is member of Group.everyone.
        subject.should_not include @event_2
      end
    end 
  end

  # News Pages
  # ------------------------------------------------------------------------------------------

  # List news (Pages) that concern the user.
  #
  #                   independent_page        <--- show
  #
  #     root_page --- page_0                  <--- show
  #         |
  #     everyone ---- page_1 ---- page_2      <--- show
  #         |
  #         |----- group_1 ---- page_3        <--- DO NOT show
  #         |
  #         |----- group_2 ---- user
  #         |        |-- page_4               <--- show
  #         |
  #         |--- user
  #
  describe "#news_pages" do
    subject { @user.news_pages }
    before do
      @independent_page = create :page, title: 'independent_page'
      @root_page = Page.find_root
      @page_0 = @root_page.child_pages.create title: 'page_0'
      @everyone = Group.everyone
      @page_1 = @everyone.child_pages.create title: 'page_1'
      @page_2 = @page_1.child_pages.create title: 'page_2'
      @group_1 = @everyone.child_groups.create name: 'group_1'
      @page_3 = @group_1.child_pages.create title: 'page_3'
      @group_2 = @everyone.child_groups.create name: 'group_2'
      @group_2.assign_user @user
      @page_4 = @group_2.child_pages.create title: 'page_4'
      time_travel 2.seconds
      @user.reload
    end
    specify 'requirements' do
      @group_1.members.should_not include @user
    end
    it "should list pages that are without group" do
      subject.should include @independent_page
    end
    it "should list pages under the root page" do
      subject.should include @page_0
    end
    it "should list pages directly under the everyone group" do
      subject.should include @page_1, @page_2
    end
    it "should NOT list pages of groups the user is not member of" do
      subject.should_not include @page_3
    end
    specify "(but users that are in @group_1 should have @page_3 listed)" do
      @user_of_group_1 = create :user
      @group_1.assign_user @user_of_group_1, at: 1.hour.ago
      @user_of_group_1.reload.news_pages.should include @page_3
    end
    it "should list pages of other groups the user is member of" do
      subject.should include @page_4
    end
  end

  # Roles
  # ==========================================================================================

  describe "#role_for" do
    before do
      @object = create( :page )
      @object.create_main_admins_parent_group
      @sub_object = create( :group ); @sub_object.parent_pages << @object
      @sub_sub_object = create( :user ); @sub_sub_object.parent_groups << @sub_object
    end
    subject { @user.role_for @object }
    context "for the user being not related to the object" do
      it { should == nil }
    end
    context "for the user being a member of the object" do
      before do
        @group = create( :group )
        @group.child_users << @user
        @object.child_groups << @group 
      end
      it { should == :member }
    end
    context "for the user being an admin of the object" do
      before { @object.admins << @user }
      it { should == :admin }
    end
    context "for the user being a main_admin of the object" do
      before { @object.main_admins << @user }
      it { should == :main_admin }
    end
    context "for the object being not structureable" do
      before { @object = "This is a string." }
      it { should == nil }
    end
    context "for descendant objects of administrated objects" do
      before { @object.admins << @user }
      it "should return the inherited role" do
        @user.role_for( @object ).should == :admin
        @user.role_for( @sub_object ).should == :admin
        @user.role_for( @sub_sub_object ).should == :admin
      end
    end
  end

  # Member Status
  # ------------------------------------------------------------------------------------------

  describe "#member_of?" do
    before do
      @group = create( :group ); @group.child_users << @user 
      @page = create( :page )
    end
    context "for the user being a descendant of the object" do
      before { @page.child_groups << @group }
      subject { @user.member_of? @page }
      it { should == true }
    end
    context "for the user not being a descendant of the object" do
      subject { @user.member_of? @page }
      it "should be false" do
        @page.descendants.should_not include @user
        subject.should == false
      end
    end
    context "for the user being a member of the group object" do
      subject { @user.member_of? @group }
      it { should == true }
    end
    context "for the argument being not able to having children, e.g. a user or another object" do
      # this is a bug fix test
      before do
        @another_user = create( :user )
        @another_object = "This is a String."
      end
      it "should be simply false and not raise an error" do
        @user.member_of?( @another_user ).should == false
        @user.member_of?( @another_object ).should == false
      end
    end
    context "for the user being a former member of the group" do
      before { @group.unassign_user @user, at: 2.minutes.ago }
      subject { @user.member_of? @group }
      it { should == false }
    end
    context "for the user being a former indirect member of the group" do
      before do
        @ancestor_group = @group.ancestor_groups.create
        @group.unassign_user @user, at: 2.minutes.ago
      end
      subject { @user.member_of? @ancestor_group }
      it { should == false }
    end
  end


  # Admins
  # ------------------------------------------------------------------------------------------

  describe "#admin_of" do
    before do 
      @group = create( :group, name: "Directly Administrated Group" )
      @group.find_or_create_admins_parent_group
      @group.admins_parent.child_users << @user
    end
    subject { @user.admin_of }
    it { should == @user.administrated_objects }
  end

  describe "#admin_of?" do
    before do
      @group = create( :group, name: "Directly Administrated Group" )
      @sub_group = create( :group, name: "Indirectly Administrated Group" )
      @sub_group.parent_groups << @group
    end
    context "for the user being admin" do
      before do
        @group.find_or_create_admins_parent_group
        @group.admins_parent.child_users << @user  # the @user is direct admin of @group
      end
      context "for directly administrated objects" do
        subject { @user.admin_of? @group }
        it "should state that the user is admin" do
          subject.should == true
        end
      end
      context "for indirectly administrated objects" do
        subject { @user.admin_of? @sub_group }
        it "should state that the user is admin" do
          subject.should == true
        end
      end
    end
    context "for the user being main admin" do
      before do
        @group.create_main_admins_parent_group
        @group.main_admins_parent.child_users << @user
      end
      subject { @user.admin_of? @group }
      it { should == true }
    end
    context "for some object the user is no admin of" do
      before { @other_object = Page.create }
      subject { @user.admin_of? @other_object }
      it { should == false }
    end
  end

  describe "#directly_administrated_objects" do
    before do
      @group = create( :group, name: "Directly Administrated Group" )
      @group.find_or_create_admins_parent_group
    end
    subject { @user.directly_administrated_objects }
    it { should be_kind_of Array }
    context "for the user being admin of objects" do
      before { @group.admins_parent.child_users << @user }
      it "should list the objects the user is directly admin of" do
        subject.should include @group
      end
    end
  end

  describe "#administrated_objects" do
    before do
      @group = create( :group, name: "Administrated Group" )
      @group.find_or_create_admins_parent_group
    end
    subject { @user.administrated_objects }
    it { should be_kind_of Array }
    context "for the user being admin of an object" do
      before { @group.admins_parent.child_users << @user }
      it "should list all objects administrated by the user" do
        @group.admins_parent.should be_kind_of Group
        @group.admins_parent.child_users.should include @user
        subject.should include @group
      end
    end
    context "for the user being an indirect admin of an object" do
      before do
        @sub_group = create( :group, name: "Indirectly Administrated Group" )
        @sub_group.parent_groups << @group
        @group.admins_parent.child_users << @user
      end
      it "should list directly and indirectly administrated objects" do
        subject.should include( @group, @sub_group )
      end
    end
  end

  # Main Admins
  # ------------------------------------------------------------------------------------------

  describe "#main_admin_of?" do
    before do
      @page = create( :page )
    end
    subject { @user.main_admin_of? @page }
    context "for the main_admins_parent_group existing" do
      before { @page.create_main_admins_parent_group }
      context "for the user being a main admin of the object" do
        before { @page.main_admins << @user }
        it { should == true }
      end
      context "for the user being just a regular admin of the object" do
        before { @page.admins << @user }
        it { should == false }
      end
      context "for the user being just a regular member of the object" do
        before do
          @group = create( :group )
          @group.child_users << @user
          @page.child_groups << @group
        end
        it "should be false" do
          @user.member_of?( @page ).should be_true # just to make sure
          subject.should == false
        end
      end
    end
  end


  # Guest Status
  # ==========================================================================================

  describe "#guest_of?" do
    before { @group = create( :group ) }
    subject { @user.guest_of? @group }
    context "for the user being not a guest of the given group" do
      it { should == false }
    end
    context "for the user being a guest of the given group" do
      before do
        @group.find_or_create_guests_parent_group
        @group.guests << @user
      end
      it { should == true }
    end
  end


  # Developers
  # ==========================================================================================

  describe "#developer?" do
    subject { @user.developer? }
    describe "for no developers group existing" do
      it { should == false }
    end
    describe "for the user being no member of the developers group" do
      before { Group.create_developers_group }
      it { should == false }
    end
    describe "for the user being member of the developers group" do
      before { Group.create_developers_group.assign_user @user }
      it { should == true }
    end
  end
  describe "#developer = " do
    describe "true" do
      subject { @user.developer = true }
      it "should assign the user to the developers group" do
        @user.should_not be_member_of Group.developers
        subject
        @user.should be_member_of Group.developers
      end
    end
    describe "false" do
      before { @user.developer = true }
      subject { @user.developer = false; time_travel 2.seconds }
      it "should un-assign the user from the developers group" do
        @user.should be_member_of Group.developers
        subject
        @user.should_not be_member_of Group.developers
      end
    end
  end


  # Hidden Users
  # ==========================================================================================

  describe '#hidden?' do
    subject { @user.hidden? }
  end

  describe '#cached(:hidden)' do
    subject { @user.cached(:hidden) }
    describe 'for the user not being hidden' do
      before do
        @user.cached(:hidden)
        wait_for_cache

        @user.hidden = true
        @user.reload
      end
      it { should == @user.hidden }
    end
    describe 'for the user being hidden' do
      before do
        @user.hidden = true
        @user.cached(:hidden)
        @user.hidden = false
      end
      it { should == @user.hidden }
    end
  end

  describe '#hidden=' do
    describe 'true' do
      subject { @user.hidden = true }
      describe 'for the user being hidden' do
        before { @user.hidden = true }
        it 'should make sure user is in the hidden_users group' do
          @user.should be_member_of Group.hidden_users
          subject
          @user.should be_member_of Group.hidden_users
        end
      end
      describe 'for the user not being hidden' do
        it 'should assign the user to the hidden_users group' do
          @user.should_not be_member_of Group.hidden_users
          subject
          @user.should be_member_of Group.hidden_users
        end
      end
    end
    describe 'false' do
      subject { @user.hidden = false; time_travel 2.seconds }
      describe 'for the user being hidden' do
        before { @user.hidden = true }
        it 'should remove the user from the hidden_users group' do
          @user.should be_member_of Group.hidden_users
          subject
          @user.should_not be_member_of Group.hidden_users
        end
      end
      describe 'for the user not being hidden' do
        it 'should make sure the user is not in the hidden_users group' do
          @user.should_not be_member_of Group.hidden_users
          subject
          @user.should_not be_member_of Group.hidden_users
        end
      end
    end
  end


  # Group Flags
  # ==========================================================================================

  describe "#group_flags" do
    before { @user = create(:user) }
    subject { @user.group_flags }
    describe "for the user being hidden" do
      before { @user.hidden = true }
      it { should include 'hidden_users' }
    end
    describe "for the user not being hidden" do
      it { should_not include 'hidden_users' }
    end
  end


  # User Creation
  # ==========================================================================================
  
  describe ".create" do
    before { @params = {first_name: "Johnny", last_name: "Doe"} }
    subject { @user = User.create(@params) }
    describe "when #add_to_corporation is set to a corporation" do
      before do
        @corporation = create(:corporation_with_status_groups)
        @params.merge!({:add_to_corporation => @corporation})
      end
      it "should add the user to the first status group of this corporation" do
        subject
        @corporation.status_groups.first.members.should include @user
      end
    end
    describe "when #add_to_corporation is set to a corporation id" do
      before do
        @corporation = create(:corporation_with_status_groups)
        @params.merge!({:add_to_corporation => @corporation.id})
      end
      it "should add the user to the first status group of this corporation" do
        subject
        @corporation.status_groups.first.members.should include @user
      end
    end
    describe "when #add_to_corporation is set to a corporation id which is a String (via html form)" do
      before do
        @corporation = create(:corporation_with_status_groups)
        @params.merge!({:add_to_corporation => @corporation.id.to_s})
      end
      it "should add the user to the first status group of this corporation" do
        subject
        @corporation.status_groups.first.members.should include @user
      end
    end
  end


  # Finder Methods
  # ==========================================================================================

  describe ".find_all_by_identification_string" do
    before do
      @user.first_name = "Some First Name"
      @user.last_name = "UniqueLastName" 
      @user.email = "unique@example.com"
      @user.alias = "s.unique"
      @user.save
    end
    describe "for a given alias" do
      subject { User.find_all_by_identification_string( @user.alias ) }
      it { should == [ @user ] }
    end
    describe "for a given last_name" do
      subject { User.find_all_by_identification_string( @user.last_name ) }
      it { should == [ @user ] }
    end
    describe "for a given name" do
      subject { User.find_all_by_identification_string( "#{@user.first_name} #{@user.last_name}" ) }
      it { should == [ @user ] }
    end
    describe "for a given email" do
      subject { User.find_all_by_identification_string( @user.email ) }
      it { should == [ @user ] }
    end
    describe "for given nonsense" do
      subject { User.find_all_by_identification_string( "f kas#dfk aoefak!" ) }
      it { should == [] }
    end
  end

  describe ".find_by_title" do
    before do
      @user.first_name = "Johnny"
      @user.last_name = "Doe"
      @user.save
      @title = @user.title 
    end
    specify { @title.should_not be_empty }
    subject { User.find_by_title( @title ) }
    it "should find the user by its title" do
      subject.should == @user 
    end
  end

  describe ".find_all_by_name" do
    before do
      @user = create( :user )
    end
    subject { User.find_all_by_name( @user.name ) }
    it { should include( @user ) }
    it "should be case-insensitive" do
      User.find_all_by_name( @user.name.upcase ).should include( @user )
      User.find_all_by_name( @user.name.downcase ).should include( @user )
    end
  end
  
  describe ".find_by_name" do
    before do
      @user = create( :user )
    end
    subject { User.find_by_name( @user.name ) }
    it { should == @user }
  end

  describe ".find_all_by_email" do
    before do
      @user = create( :user )
    end
    subject { User.find_all_by_email( @user.email ) }
    it { should include( @user ) }
    it "should be case-insensitive" do
      User.find_all_by_email( @user.email.upcase ).should include( @user )
      User.find_all_by_email( @user.email.downcase ).should include( @user )
    end
  end
  
  describe ".hidden" do
    before do
      @hidden_user = create(:user); @hidden_user.hidden = true
      @visible_user = create(:user)
    end
    subject { User.hidden }
    it { should be_kind_of ActiveRecord::Relation }
    it { should include @hidden_user }
    it { should_not include @visible_user }
    it "should be chainable" do
      subject.where(id: @hidden_user.id).should == User.where(id: @hidden_user.id).hidden
      subject.count.should > 0
    end
  end
  
  describe ".deceased" do
    before do
      @deceased_user = create(:user); @deceased_user.mark_as_deceased(at: 1.year.ago)
      @alive_user = create(:user)
    end
    subject { User.deceased }
    it { should be_kind_of ActiveRecord::Relation }
    it { should include @deceased_user }
    it { should_not include @alive_user }
    it "should be chainable" do
      subject.where(id: @deceased_user.id).to_a.should == User.where(id: @deceased_user.id).deceased.to_a
    end
  end

  describe ".alive" do
    before do
      @deceased_user = create(:user); @deceased_user.mark_as_deceased(at: 1.year.ago)
      @alive_user = create(:user)
    end
    subject { User.alive }
    it { should be_kind_of ActiveRecord::Relation }
    it { should_not include @deceased_user }
    it { should include @alive_user }
    it "should be chainable" do
      subject.where(id: @alive_user.id).to_a.should == User.where(id: @alive_user.id).alive.to_a
    end
    specify "there should be no user that is deceased and alive" do
      User.alive.deceased.should == []
      User.deceased.alive.should == []
    end
  end
  
  describe ".without_account" do
    before do
      @user_with_account = create(:user_with_account)
      @user_without_account = create(:user)
    end
    subject { User.without_account }
    it { should be_kind_of ActiveRecord::Relation }
    it { should include @user_without_account }
    it { should_not include @user_with_account }
    it "should be chainable" do
      subject.where(id: @user_without_account.id).to_a.should == User.where(id: @user_without_account.id).without_account.to_a
    end
  end
  
  describe ".with_email" do
    before do
      @user_with_email = create(:user)
      @user_without_email = create(:user)
      @user_without_email.profile_fields.destroy_all
      @user_with_empty_email = create(:user)
      @user_with_empty_email.profile_fields.where(type: 'ProfileFieldTypes::Email').first.update_attributes(:value => '')  # to circumvent validation
    end
    subject { User.with_email }
    specify "prelims" do
      @user_with_empty_email.email.should == ""
    end
    it { should be_kind_of ActiveRecord::Relation }
    it { should include @user_with_email }
    it { should_not include @user_without_email }
    it { should_not include @user_with_empty_email }
    it "should be chainable" do
      subject.where(id: @user_with_email.id).to_a.should == User.where(id: @user_with_email.id).with_email.to_a
    end
  end
  
  describe ".applicable_for_new_account" do
    before do
      @hidden_user = create(:user); @hidden_user.hidden = true
      @visible_user = create(:user)
      @deceased_user = create(:user); @deceased_user.mark_as_deceased(at: 1.year.ago)
      @alive_user = create(:user)
      @user_with_account = create(:user_with_account)
      @user_without_account = create(:user)
      @user_with_email = create(:user)
      @user_without_email = create(:user)
      @user_without_email.profile_fields.destroy_all
      @user_with_empty_email = create(:user)
      @user_with_empty_email.profile_fields.where(type: 'ProfileFieldTypes::Email').first.update_attributes(:value => '')
    end
    subject { User.applicable_for_new_account }
    it { should be_kind_of ActiveRecord::Relation }
    it { should include @hidden_user }
    it { should include @visible_user }
    it { should_not include @deceased_user }
    it { should include @alive_user }
    it { should_not include @user_with_account }
    it { should include @user_without_account }
    it { should include @user_with_email }
    it { should_not include @user_without_email }
    it { should_not include @user_with_empty_email }
  end
  
  describe "(postal address finder methods)" do
    before do
      @user_with_address = create(:user)
      @user_with_address.profile_fields.create(type: 'ProfileFieldTypes::Address', value: "Pariser Platz 1\n 10117 Berlin")
      @user_without_address = create(:user)
      @user_with_empty_address = create(:user)
      @user_with_empty_address.profile_fields.create(type: 'ProfileFieldTypes::Address', value: "")
    end
  
    describe ".with_postal_address" do
      subject { User.with_postal_address }
      it { should be_kind_of ActiveRecord::Relation }
      it { should include @user_with_address }
      it { should_not include @user_without_address }
      it { should_not include @user_with_empty_address }
    end
    
    describe ".without_postal_address" do
      subject { User.without_postal_address }
      it { should be_kind_of ActiveRecord::Relation }
      it { should include @user_without_address }
      it { should include @user_with_empty_address }
      it { should_not include @user_with_address }
    end
  end

end

