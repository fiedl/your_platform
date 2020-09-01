require 'spec_helper'

describe ProfileFields::Address do
  before { @profile_field = ProfileFields::Address.create label: 'Address' }
  subject { @profile_field }

  describe "when a free-text address is stored that can be geocoded" do
    before { @profile_field.update_attributes value: "Pariser Platz 1\n 10117 Berlin" }

    its(:street_with_number) { should == 'Pariser Platz 1' }
    its(:postal_code) { should == '10117' }
    its(:city) { should == 'Berlin' }
    its(:value) { should == "Pariser Platz 1\n 10117 Berlin" }
    its('country_code.downcase') { should == 'de' }
  end

  describe "when a free-text address is stored that cannot be geocoded" do
    before { @profile_field.update_attribute :value, "Postfach 1234\n10117 Berlin" }

    its(:street_with_number) { should == nil }
    its(:postal_code) { should == nil }
    its(:city) { should == nil }
    its(:value) { should == "Postfach 1234\n10117 Berlin" }
    its('country_code.downcase') { should == @profile_field.default_country_code.downcase }
  end

  describe "for a french address that can be geocoded" do
    before { @profile_field.update_attributes value: "44 Rue de Stalingrad, Grenoble, Frankreich" }

    its(:street_with_number) { should include '44' }
    its(:street_with_number) { should include 'Rue de Stalingrad' }
    its(:postal_code) { should == '38100' }
    its(:city) { should == 'Grenoble' }
    its(:value) { should == "44 Rue de Stalingrad, Grenoble, Frankreich" }
    its('country_code.downcase') { should == 'fr' }
  end
end