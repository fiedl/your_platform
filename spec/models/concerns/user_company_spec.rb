require 'spec_helper'

describe User::Company do
  before do
    @user = create :user
    @group = create :group
    @company = create :company
  end
  
  describe "#company" do
    subject { @user.company }
    
    describe "for a fresh user" do
      it { should == nil }
    end
    
    describe "with the user being member of a company" do
      before do
        @group << @user
        @company << @user
      end
      it { should == @company }
    end
  end
  
  describe "#company_name" do
    subject { @user.company_name }
    
    describe "for a fresh user" do
      it { should == nil }
    end
    
    describe "with the user being member of a company" do
      before do
        @group << @user
        @company << @user
      end
      it { should == @company.name }
    end
  end
  
  describe "#company_name=" do
    subject { @user.company_name = "My Great Company, Inc." }
    
    describe "when the company does not exist" do
      specify { subject; @user.company_name.should == "My Great Company, Inc." }

      it "should create the company" do
        subject
        Company.pluck(:name).should include "My Great Company, Inc."
      end
      
      it "should assing the user to the company" do
        subject
        Company.where(name: "My Great Company, Inc.").first.members.should include @user
      end
    end
    
    describe "when the company exists" do
      before { @great_company = Company.create name: "My Great Company, Inc." }
      
      specify { subject; @user.company_name.should == "My Great Company, Inc." }
      
      it "should assign the user to the existing company" do
        subject
        @user.company.should == @great_company
      end
    end
  end
  
end