require 'spec_helper'

describe Bv do

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