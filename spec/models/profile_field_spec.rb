# -*- coding: utf-8 -*-
require 'spec_helper'

describe ProfileField do
  let(:user) { FactoryGirl.create(:user)}
  before { @profile_field = user.profile_fields.build() }
  
  subject { @profile_field }
  
  it { should respond_to(:profileable_id) }
  it { should respond_to(:label) }
  it { should respond_to(:type) }
  it { should respond_to(:value) }
  its(:profileable) { should eq user }
  
  it { should be_valid }
end
