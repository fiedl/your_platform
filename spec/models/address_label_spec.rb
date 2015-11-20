require 'spec_helper'

describe AddressLabel do
  before do
    @user = create :user
    
    @address_field = @user.profile_fields.create(type: 'ProfileFieldTypes::Address', value: "Pariser Platz 1\n 10117 Berlin").becomes(ProfileFieldTypes::Address)
    
    @name_surrounding = @user.profile_fields.create(type: 'ProfileFieldTypes::NameSurrounding').becomes(ProfileFieldTypes::NameSurrounding)
    @name_surrounding.name_prefix = "Dr."
    @name_surrounding.name_suffix = "M.Sc."
    @name_surrounding.text_above_name = "Herrn"
    @name_surrounding.text_below_name = "Bankdirektor"
    @name_surrounding.save
    @user.save
    
  end
  
  let(:address_label) { AddressLabel.new(@user.name, @address_field, @name_surrounding, @user.personal_title) }
    
  
  describe "#name" do
    subject { address_label.name }
    it { should == @user.name }
  end
  
  describe "#postal_address" do
    subject { address_label.postal_address }
    it { should == @user.postal_address }
  end
  
  describe "#postal_code" do
    subject { address_label.postal_code }
    it { should == @address_field.postal_code }
    it { should == "10117"}
  end
  
  describe "#country_code" do 
    subject { address_label.country_code }
    it { should == @address_field.country_code }
    it { should == "de" }
  end
  
  describe "#text_above_name" do
    subject { address_label.text_above_name }
    it { should == @name_surrounding.text_above_name }
  end
  
  describe "#text_below_name" do
    subject { address_label.text_below_name }
    it { should == @name_surrounding.text_below_name }
  end
  
  describe "#name_prefix" do
    subject { address_label.name_prefix }
    it { should == @name_surrounding.name_prefix }
  end
  
  describe "#name_suffix" do
    subject { address_label.name_suffix }
    it { should == @name_surrounding.name_suffix }
  end
  
  describe "#personal_title" do
    subject { address_label.personal_title }
    before do
      @user.profile_fields.create(type: 'ProfileFieldTypes::General', label: 'personal_title', value: "Dr.")
      @user.save
    end
    it { should == @user.personal_title }
  end
  
  describe "#to_s" do
    subject { address_label.to_s }

    it { should == 
      "Herrn\n" +
      "Dr. #{@user.first_name} #{@user.last_name} M.Sc.\n" + 
      "Bankdirektor\n" +
      "Pariser Platz 1\n" + 
      "10117 Berlin"
    }
    describe "when no name surroundings are given" do
      before { @name_surrounding.destroy }
      it { should == "#{@user.name}\nPariser Platz 1\n10117 Berlin" }
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
        "Pariser Platz 1\n" + 
        "10117 Berlin"
      end
    end
    describe "when there is no text below the name" do
      before { @name_surrounding.update_attributes(text_below_name: nil) }
      it "should leave no blank line" do
        subject.should == 
        "Herrn\n" +
        "Dr. #{@user.first_name} #{@user.last_name} M.Sc.\n" + 
        "Pariser Platz 1\n" + 
        "10117 Berlin"
      end
    end
    describe "when there is no text above the name" do
      before { @name_surrounding.update_attributes(text_above_name: nil) }
      it "should not begin with a blnak line" do
        subject.should == 
        "Dr. #{@user.first_name} #{@user.last_name} M.Sc.\n" + 
        "Bankdirektor\n" +
        "Pariser Platz 1\n" + 
        "10117 Berlin"
      end
    end
    describe "when there is neither prefix nor personal title" do
      before { @name_surrounding.update_attributes(name_prefix: nil) }
      it "should set no spaces before the name" do
        subject.should == 
        "Herrn\n" +
        "#{@user.first_name} #{@user.last_name} M.Sc.\n" + 
        "Bankdirektor\n" +
        "Pariser Platz 1\n" + 
        "10117 Berlin"
      end
    end
    describe "when there is no name suffix" do
      before { @name_surrounding.update_attributes(name_suffix: nil) }
      it "should set no spaces after the name" do
        subject.should == 
        "Herrn\n" +
        "Dr. #{@user.first_name} #{@user.last_name}\n" + 
        "Bankdirektor\n" +
        "Pariser Platz 1\n" + 
        "10117 Berlin"
      end
    end
  end
end