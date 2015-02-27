require 'spec_helper'

describe Bv do
  
  describe "for an empty database" do
    describe ".all" do
      subject { Bv.all }
      it { should == [] }
    end
    describe ".pluck(:id)" do
      subject { Bv.pluck(:id) }
      it { should == [] }
    end
  end
  
  describe "with a bv and a group in the database" do
    before do
      @bv = create :bv
      @other_group = create :group
    end
    
    describe ".all" do
      subject { Bv.all }
      it { should include @bv }
      it { should_not include @other_group }
    end
    
    describe ".pluck(:id)" do
      subject { Bv.pluck(:id) }
      it { should include @bv.id }
      it { should_not include @other_group.id }
    end
  end

end