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

  describe "#first_name" do
    subject { @user.first_name }
    describe "when containing illegal spaces" do
      before { @user.first_name = " John " }
      describe "after saving" do
        before { @user.save }
        it "should be stripped" do
          @user.first_name.should == "John"
        end
      end
    end
  end

  describe "#last_name" do
    subject { @user.last_name }
    describe "when containing illegal spaces" do
      before { @user.last_name = " Doe " }
      describe "after saving" do
        before { @user.save }
        it "should be stripped" do
          @user.last_name.should == "Doe"
        end
      end
    end
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

  describe "#summary_string" do
    subject { @user.summary_string }
    before do
      @user = User.create last_name: "Wein", first_name: "Björn"
      @user.localized_date_of_birth = "19.12.1980"
      @user.home_address = "Feinhäuser Allee 25, 35037 Marburg"
      @user.phone = "06421-12345"
      @user.academic_degree = "Dr.rer.nat."
      @user.save

      @user.profile_fields.create type: "ProfileFields::ProfessionalCategory", label: "employment_title", value: "Winzer"
    end

    it { should == "Wein, Björn, *19.12.1980, Dr.rer.nat., Winzer, Feinhäuser Allee 25, 35037 Marburg, 06421-12345" }

    describe "with email" do
      before { @user.email = "wein@example.com"; @user.save; @user.delete_cache }

      it { should == "Wein, Björn, *19.12.1980, Dr.rer.nat., Winzer, Feinhäuser Allee 25, 35037 Marburg, 06421-12345, wein@example.com" }
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
      its(:type) { should == "ProfileFields::Date" }
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
      its(:type) { should == "ProfileFields::Date" }
      its(:new_record?) { should == true }
    end
    describe "for an existing date of birth" do
      before { @user.date_of_birth = "1900-01-01".to_date }
      it { should be_kind_of ProfileField }
      its(:type) { should == "ProfileFields::Date" }
    end
    describe "for a date of birth existing in the database" do
      before do
        @user.date_of_birth = "1900-01-01".to_date
        @user.save
        @user = User.find(@user.id)
      end
      it { should be_kind_of ProfileField }
      its(:type) { should == "ProfileFields::Date" }
      its('value.to_date') { should == "1900-01-01".to_date }
      its(:new_record?) { should == false }
    end
  end
  describe "#find_or_create_date_of_birth_profile_field" do
    subject { @user.find_or_create_date_of_birth_profile_field }
    describe "for no date of birth field existing" do
      it { should be_kind_of ProfileField }
      its(:type) { should == "ProfileFields::Date" }
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
       its(:type) { should == "ProfileFields::Date" }
       its('value.to_date') { should == "1900-01-01".to_date }
       its(:new_record?) { should == false }
     end
  end

  describe "#age" do
    subject { @user.age }
    describe "without date of birth" do
      it { should == nil }
    end
    describe "with date of birth" do
      before { @user.date_of_birth = 24.years.ago; @user.save }
      it "should return the correct age as number" do
        subject.should == 24
      end
    end
  end

  describe "#birthday_this_year" do
    subject { @user.birthday_this_year }
    describe "without date of birth" do
      it { should == nil }
    end
    describe "with date of birth" do
      before { @user.date_of_birth = 24.years.ago; @user.save }
      it "should return the correct date" do
        subject.should == Time.zone.now.to_date
      end
    end
  end

  describe "postal address: " do
    before do
      @other_field = ProfileFields::Address.create(label: "My Work", value: "Some Other Address")
      @profile_field = ProfileFields::Address.create(label: "My Home", value: "Some Address")
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
      subject { @user.reload.postal_address_with_name_surrounding }
      before do
        @name_surrounding = @user.profile_fields.create(type: 'ProfileFields::NameSurrounding').becomes(ProfileFields::NameSurrounding)
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
          @user.profile_fields.create(type: 'ProfileFields::General', label: 'personal_title', value: "Dr.")
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
        before { @name_surrounding.update_attributes(text_below_name: nil) }
        it "should leave no blank line" do
          subject.should ==
          "Herrn\n" +
          "Dr. #{@user.first_name} #{@user.last_name} M.Sc.\n" +
          @user.postal_address
        end
      end
      describe "when there is no text above the name" do
        before { @name_surrounding.update_attributes(text_above_name: nil) }
        it "should not begin with a blnak line" do
          subject.should ==
          "Dr. #{@user.first_name} #{@user.last_name} M.Sc.\n" +
          "Bankdirektor\n" +
          @user.postal_address
        end
      end
      describe "when there is neither prefix nor personal title" do
        before { @name_surrounding.update_attributes(name_prefix: nil) }
        it "should set no spaces before the name" do
          subject.should ==
          "Herrn\n" +
          "#{@user.first_name} #{@user.last_name} M.Sc.\n" +
          "Bankdirektor\n" +
          @user.postal_address
        end
      end
      describe "when there is no name suffix" do
        before { @name_surrounding.update_attributes(name_suffix: nil) }
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
      @phone_field = @user.profile_fields.create(label: 'Phone', type: 'ProfileFields::Phone', value: '123456').becomes(ProfileFields::Phone)
      @fax_field = @user.profile_fields.create(label: 'Fax', type: 'ProfileFields::Phone', value: '123457').becomes(ProfileFields::Phone)
      @mobile_field = @user.profile_fields.create(label: 'Mobile', type: 'ProfileFields::Phone', value: '01234').becomes(ProfileFields::Phone)
      @user.reload
    end
    it { should include @phone_field }
    it { should_not include @fax_field }
    it { should include @mobile_field }
  end

  describe "#phone" do
    subject { @user.phone }
    describe "for a phone number given" do
      before { @phone_field = @user.profile_fields.create(label: 'Phone', type: 'ProfileFields::Phone', value: '09131 123 45 67').becomes(ProfileFields::Phone) }
      it { should == @phone_field.value }
    end
    describe "for a phone and a mobile number given" do
      before do
        @mobile_field = @user.profile_fields.create(label: 'Mobile', type: 'ProfileFields::Phone', value: '09131 123 45 67').becomes(ProfileFields::Phone)
        @phone_field = @user.profile_fields.create(label: 'Phone', type: 'ProfileFields::Phone', value: '0171 123 45 67').becomes(ProfileFields::Phone)
      end
      it { should == @phone_field.value }
    end
    describe "for no phone number given" do
      it { should == nil }
    end
  end

  describe "#phone=" do
    before { @new_phone_number = "+49 9131 123 45" }
    subject { @user.phone = @new_phone_number }
    describe "if no phone field is present" do
      it "should create a new one" do
        @user.phone_profile_fields.count.should == 0
        subject
        @user.phone_profile_fields.first.value.should == @new_phone_number
        @user.phone_profile_fields.first.label.should == "Telefon"
      end
    end
    describe "if a phone field is present" do
      before { @phone_field = @user.profile_fields.create(label: 'Telefon', value: '09131 123 45 56', type: 'ProfileFields::Phone') }
      it "should modify the existing one" do
        subject
        @phone_field.reload.value.should == @new_phone_number
      end
    end
  end

  describe "#mobile" do
    subject { @user.mobile }
    describe "for a mobile phone number given" do
      before { @phone_field = @user.profile_fields.create(label: 'Mobile', type: 'ProfileFields::Phone', value: '0161 123 45 67').becomes(ProfileFields::Phone) }
      it { should == @phone_field.value }
    end
    describe "for a phone and a mobile number given" do
      before do
        @phone_field = @user.profile_fields.create(label: 'Phone', type: 'ProfileFields::Phone', value: '0171 123 45 67').becomes(ProfileFields::Phone)
        @mobile_field = @user.profile_fields.create(label: 'Mobile', type: 'ProfileFields::Phone', value: '09131 123 45 67').becomes(ProfileFields::Phone)
      end
      it { should == @mobile_field.value }
    end
    describe "for no phone number given" do
      it { should == nil }
    end
  end
  describe "#mobile=" do
    before { @new_phone_number = "+49 9131 123 45" }
    subject { @user.mobile = @new_phone_number }
    describe "if no phone field is present" do
      it "should create a new one" do
        @user.phone_profile_fields.count.should == 0
        subject
        @user.phone_profile_fields.first.value.should == @new_phone_number
        @user.phone_profile_fields.first.label.should == "Mobil"
      end
    end
    describe "if a phone field is present" do
      before { @phone_field = @user.profile_fields.create(label: 'Mobil', value: '0161 123 45 56', type: 'ProfileFields::Phone') }
      it "should modify the existing one" do
        subject
        @phone_field.reload.value.should == @new_phone_number
      end
    end
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

  specify "changed behaviour: on creating the default alias should be nil" do
    @user = User.create(first_name: "James", last_name: "Doe", email: "doe@example.com")
    @user.alias.should == nil
  end

  describe "when two users have the same alias by mistake" do
    before do
      @user1 = create :user_with_account
      @user1.update_attribute :alias, "john"
      @user2 = create :user_with_account
      @user2.update_attribute :alias, "john"
    end

    describe "saving! a user" do
      subject { @user1.accepted_terms_at = Time.zone.now; @user1.save! }
      it "should not raise an error" do
        expect { subject }.to_not raise_error
      end
      it "should regenerate the alias" do
        subject
        @user1.alias.should_not == "john"
      end
    end
  end
  describe "when the alias is uniqe" do
    before do
      @user1 = create :user_with_account
      @user1.update_attribute :alias, "john"
    end

    describe "saving! a user" do
      subject { @user1.accepted_terms_at = Time.zone.now; @user1.save! }
      it "should not raise an error" do
        expect { subject }.to_not raise_error
      end
      it "should not change the alias" do
        old_alias = @user1.alias
        subject
        @user1.alias.should == old_alias
      end
    end
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
    it "should return a relation of Corporation-type objects" do
      subject.should be_kind_of ActiveRecord::Relation
      subject.first.should be_kind_of Corporation
    end
  end

  describe "#corporations" do
    before do
      @corporationE = create( :corporation_with_status_groups, :token => "E" )
      @corporationS = create( :corporation_with_status_groups, :token => "S" )
      @corporationH = create( :corporation_with_status_groups, :token => "H" )
      @subgroup = create( :group );
      @subgroup.parent_groups << @corporationE
      @user.save
      @first_membership_E = Memberships::Status.create(user: @user, group: @corporationE.status_groups.first)
      @user.parent_groups << @subgroup
      @user.reload
    end
    subject { @user.corporations }
    it "should return an array of the user's corporations" do
      should == [@corporationE]
    end
    context "when user entered corporation S" do
      before do
        @user.corporations
        wait_for_cache

        first_membership_S = Memberships::Status.create(user: @user, group: @corporationS.status_groups.first)
        first_membership_S.update_attributes(valid_from: "2010-05-01".to_datetime)
        @user.reload
      end
      it { should == [@corporationE, @corporationS] }
    end
    context "when user entered corporation H as guest" do
      before do
        @user.corporations
        wait_for_cache

        first_membership_H = Memberships::Status.create(user: @user, group: @corporationH.guests_parent)
        first_membership_H.update_attributes(valid_from: "2010-05-01".to_datetime)
        @user.reload
      end
      it { should == [@corporationE, @corporationH] }
    end
    context "when user left corporation E" do
      before do
        @user.corporations
        former_group = @corporationE.child_groups.create
        former_group.add_flag :former_members_parent
        second_membership_E = Memberships::Status.create(user: @user, group: former_group)
        second_membership_E.update_attributes(valid_from: "2014-05-01".to_datetime)
        @first_membership_E.update_attributes(valid_to: "2014-05-01".to_datetime)
        @user.reload
      end
      it { should == [@corporationE] }
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
      @first_membership_E = Memberships::Status.create(user: @user, group: @corporationE.status_groups.first)
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
        first_membership_S = Memberships::Status.create(user: @user, group: @corporationS.status_groups.first)
        first_membership_S.update_attributes(valid_from: "2010-05-01".to_datetime)
        @user.reload
      end
      it { should == [ @corporationE, @corporationS ] }
    end
    context "when user entered corporation H as guest" do
      before do
        first_membership_H = Memberships::Status.create(user: @user, group: @corporationH.guests_parent)
        first_membership_H.update_attributes(valid_from: "2010-05-01".to_datetime)
        @user.reload
      end
      it { should == [ @corporationE ] }
    end
    context "when user left corporation E" do
      before do
        former_group = @corporationE.child_groups.create
        former_group.add_flag :former_members_parent
        second_membership_E = Memberships::Status.create(user: @user, group: former_group)
        second_membership_E.update_attributes(valid_from: "2014-05-01".to_datetime)
        @first_membership_E.update_attributes(valid_to: "2014-05-01".to_datetime)
        run_background_jobs  # to update the indirect validity ranges
        @user.reload
      end
      it { should be_empty }
    end
    context "when joining an event of a corporation" do
      before do
        @event = @corporationH.events.create
        @user.join @event
        time_travel 2.seconds; @user.reload
      end
      it { should_not include @corporationH }
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
      @first_membership_E = Memberships::Status.create(user: @user, group: @corporationE.status_groups.first)
      @user.parent_groups << @subgroup
      @user.reload
    end
    subject { @user.current_corporations }
    it "should return an array of the user's corporations" do
      should == @user.corporations
    end
    context "when user entered corporation S" do
      before do
        @user.current_corporations
        wait_for_cache

        first_membership_S = Memberships::Status.create(user: @user, group: @corporationS.status_groups.first)
        first_membership_S.update_attributes(valid_from: "2010-05-01".to_datetime)
        run_background_jobs  # to update the indirect validity ranges
        @user.reload
      end
      it { should == [ @corporationE, @corporationS ] }
    end
    context "when user entered corporation H as guest" do
      before do
        @user.current_corporations
        first_membership_H = Memberships::Status.create(user: @user, group: @corporationH.guests_parent)
        first_membership_H.update_attributes(valid_from: "2010-05-01".to_datetime)
        @user.reload
      end
      it { should == [ @corporationE ] }
    end
    context "when user left corporation E" do
      before do
        @user.current_corporations
        wait_for_cache

        former_group = @corporationE.child_groups.create
        former_group.add_flag :former_members_parent
        second_membership_E = Memberships::Status.create(user: @user, group: former_group)
        second_membership_E.update_attributes(valid_from: "2014-05-01".to_datetime)
        @first_membership_E.update_attributes(valid_to: "2014-05-01".to_datetime)
        run_background_jobs  # to update the indirect validity ranges
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
      @corporation1.assign_admin @user
      time_travel 5.seconds
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
      @corporation1.assign_admin @user
      @user.reload
    end
    subject { @user.last_group_in_first_corporation }
    it "should return the last non special group of user's first corporation" do
      subject.should == @corporation1.status_groups.last
      subject.should_not == @corporation1.admins_parent
    end
  end


  # Memberships
  # ------------------------------------------------------------------------------------------

  describe "#memberships" do
    before do
      @group = create( :group )
      @group.child_users << @user
      @membership = Membership.find_by( user: @user, group: @group )
    end
    subject { @user.memberships }
    it "should return an array of the user's memberships" do
      subject.should == [ @membership ]
    end
    it "should be the same as Membership.find_all_by_user" do
      subject.should == Membership.find_all_by_user( @user )
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
        @upcoming_events = [ @group1.events.create( start_at: 5.hours.from_now ),
                             @group2.events.create( start_at: 6.hours.from_now ) ]
        @recent_events = [ @group1.events.create( start_at: 2.days.ago ) ]
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
        @event_0 = @group_a.events.create( start_at: 5.hours.from_now )
        @group_b = @group_a.child_groups.create
        @group_b.child_users << @user
        @event_1 = @group_b.events.create( start_at: 5.hours.from_now )
        @group_c = @group_a.child_groups.create
        @event_2 = @group_c.events.create( start_at: 5.hours.from_now )
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

  describe "#join" do
    subject { @user.join(@event_or_group); time_travel(2.seconds) }
    describe "(joining an event)" do
      before { @event_or_group = @event = create(:event); subject }
      specify { @event.attendees.should include @user}
      specify { @event.attendees_group.members.should include @user }
      specify "the user should be able to join and leave and re-join without error" do
        @user.join @event; time_travel 2.seconds
        @user.leave @event; time_travel 2.seconds
        @user.join @event; time_travel 2.seconds
        @event.attendees.should include @user
      end
    end
    describe "(joining a group)" do
      before { @event_or_group = @group = create(:group); subject }
      specify { @group.members.should include @user }
    end
  end
  describe "#leave" do
    subject { @user.leave(@event_or_group); time_travel(2.seconds) }
    before do
      @event = create :event; @user.join @event
      @group = create :group; @user.join @group
      time_travel 2.seconds
    end
    describe "(leaving an event)" do
      # TODO: We need multiple dag links between two nodes!
      before { @event_or_group = @event; subject }
      specify { @event.attendees.should_not include @user}
      specify { @event.attendees_group.members.should_not include @user }
      specify { @event.attendees_group.child_users.should_not include @user }
    end
    describe "(leaving a group)" do
      before { @event_or_group = @group; subject }
      # TODO: We need multiple dag links between two nodes!
      # specify { @group.members.should_not include @user }
      # specify { @group.members.former.should include @user }
      # specify { @group.child_users.should include @user }
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
      @independent_page = create :page, title: 'independent_page', published_at: 1.day.ago
      @root_page = Page.find_root
      @page_0 = @root_page.child_pages.create title: 'page_0', published_at: 1.day.ago
      @everyone = Group.everyone
      @page_1 = @everyone.child_pages.create title: 'page_1', published_at: 1.day.ago
      @page_2 = @page_1.child_pages.create title: 'page_2', published_at: 1.day.ago
      @group_1 = @everyone.child_groups.create name: 'group_1'
      @page_3 = @group_1.child_pages.create title: 'page_3', published_at: 1.day.ago
      @group_2 = @everyone.child_groups.create name: 'group_2'
      @group_2.assign_user @user
      @page_4 = @group_2.child_pages.create title: 'page_4', published_at: 1.day.ago
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
      before do
        @group.unassign_user @user, at: 2.minutes.ago
      end
      subject { @user.member_of? @group }
      it { should == false }
    end
    context "for the user being a former indirect member of the group" do
      before do
        @ancestor_group = @group.ancestor_groups.create
        @group.unassign_user @user, at: 2.minutes.ago
        run_background_jobs  # to update the indirect validity ranges
      end
      subject { @user.member_of? @ancestor_group }
      it { should == false }
    end
  end


  # Hidden Users
  # ==========================================================================================

  describe '#hidden?' do
    subject { @user.hidden? }
  end

  describe '#hidden' do
    subject { @user.hidden }
    describe 'for the user not being hidden' do
      it { should == false }
    end
    describe 'for the user being hidden' do
      before { Group.hidden_users.assign_user @user; @user.reload }
      it { should == true }
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
          @user.reload.should be_member_of Group.hidden_users
        end
      end
      describe 'for the user not being hidden' do
        it 'should assign the user to the hidden_users group' do
          @user.should_not be_member_of Group.hidden_users
          subject
          @user.reload.should be_member_of Group.hidden_users
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
          @user.reload.should_not be_member_of Group.hidden_users
        end
      end
      describe 'for the user not being hidden' do
        it 'should make sure the user is not in the hidden_users group' do
          @user.should_not be_member_of Group.hidden_users
          subject
          @user.reload.should_not be_member_of Group.hidden_users
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
      subject { User.find_all_by_identification_string("unique@example.com") }
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
      subject.where(id: @hidden_user.id).to_a.should == User.where(id: @hidden_user.id).hidden.to_a
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
      @user_with_empty_email.profile_fields.where(type: 'ProfileFields::Email').first.update_attributes(:value => nil)  # to circumvent validation
    end
    subject { User.with_email }
    specify "prelims" do
      @user_with_empty_email.email.should == nil
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
      @user_with_empty_email.profile_fields.where(type: 'ProfileFields::Email').first.update_attribute(:value, '')
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
      @user_with_address.profile_fields.create(type: 'ProfileFields::Address', value: "Pariser Platz 1\n 10117 Berlin")
      @user_without_address = create(:user)
      @user_with_empty_address = create(:user)
      @user_with_empty_address.profile_fields.create(type: 'ProfileFields::Address', value: "")
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
