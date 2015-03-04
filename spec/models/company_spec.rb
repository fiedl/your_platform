require 'spec_helper'

describe Company do
  before do
    @group = create :group
    @company = create :company
  end
    
  describe ".create" do
    subject { Company.create name: 'My Great Company, Inc.' }
    
    it { should be_kind_of Company }
    it { should be_kind_of Group }
    its(:type) { should == 'Company' }

    it "should be child of the all-companies group" do
      subject.reload.parent_group_ids.should include Company.companies_parent.id
    end
  end
  
  describe ".all" do
    subject { Company.all }
    
    it { should include @company }
    it { should_not include @group }
  end
  
  describe "pluck(:id)" do
    subject { Company.pluck(:id) }
    
    it { should include @company.id }
    it { should_not include @group.id }
  end 
  
  describe ".companies_parent" do
    subject { Company.companies_parent }
    
    it { should be_kind_of Group }
    it { should_not be_kind_of Company }
    its(:children) { should include @company }
    its(:children) { should_not include @group }
  end

end