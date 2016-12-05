require 'spec_helper'

describe ProfileFieldTypes::Address do
  before { @profile_field = ProfileFieldTypes::Address.create label: 'Address' }
  subject { @profile_field }

  describe "when a free-text address is stored that can be geocoded" do
    before { @profile_field.update_attributes value: "Pariser Platz 1\n 10117 Berlin" }

    its(:street_with_number) { should == 'Pariser Platz 1' }
    its(:postal_code) { should == '10117' }
    its(:city) { should == 'Berlin' }
    its(:value) { should == "Pariser Platz 1\n 10117 Berlin" }
    its('country_code.downcase') { should == 'de' }

    describe "after #convert_to_format_with_separate_fields" do
      before { @profile_field.convert_to_format_with_separate_fields }

      its(:children_count) { should > 0 }
      its(:street_with_number) { should == 'Pariser Platz 1' }
      its(:first_address_line) { should == 'Pariser Platz 1' }
      its(:postal_code) { should == '10117' }
      its(:city) { should == 'Berlin' }
      its(:value) { should == "Pariser Platz 1\n10117 Berlin" }
      its('country_code.downcase') { should == 'de' }
      it { should_not have_flag :needs_review }

      specify "the conversion should be persistent" do
        subject
        @reloaded_field = ProfileField.find(@profile_field.id)
        @reloaded_field.children_count.should > 0
        @reloaded_field.street_with_number.should == 'Pariser Platz 1'
        @reloaded_field.postal_code.should == '10117'
        @reloaded_field.city.should == 'Berlin'
        @reloaded_field.value.should == "Pariser Platz 1\n10117 Berlin"
      end

      describe "after #convert_to_format_with_separate_fields twice" do
        before do
          @profile_field = ProfileField.find @profile_field.id
          @profile_field.convert_to_format_with_separate_fields
        end

        its(:children_count) { should > 0 }
        its(:street_with_number) { should == 'Pariser Platz 1' }
        its(:first_address_line) { should == 'Pariser Platz 1' }
        its(:postal_code) { should == '10117' }
        its(:city) { should == 'Berlin' }
        its(:value) { should == "Pariser Platz 1\n10117 Berlin" }
        its('country_code.downcase') { should == 'de' }
        it { should_not have_flag :needs_review }
      end
    end
  end

  describe "when a free-text address is stored that cannot be geocoded" do
    before { @profile_field.update_attribute :value, "Postfach 1234\n10117 Berlin" }

    its(:street_with_number) { should == nil }
    its(:postal_code) { should == nil }
    its(:city) { should == nil }
    its(:value) { should == "Postfach 1234\n10117 Berlin" }
    its('country_code.downcase') { should == @profile_field.default_country_code.downcase }

    describe "after #convert_to_format_with_separate_fields" do
      before { @profile_field.convert_to_format_with_separate_fields }

      its(:street_with_number) { should == nil }
      its(:second_address_line) { should == "Postfach 1234\n10117 Berlin" }
      its(:postal_code) { should == nil }
      its(:city) { should == nil }
      its(:value) { should == "Postfach 1234\n10117 Berlin" }
      its('country_code.downcase') { should == @profile_field.default_country_code.downcase }
      it { should have_flag :needs_review }
    end
  end

  describe "when separate fields are stored that cannot be geocoded" do
    before do
      @profile_field.first_address_line = 'Postfach 1234'
      @profile_field.postal_code = '10117'
      @profile_field.city = 'Berlin'
      @profile_field.save
    end

    its(:street_with_number) { should == 'Postfach 1234' }
    its(:postal_code) { should == '10117' }
    its(:city) { should == 'Berlin' }
    its(:value) { should == "Postfach 1234\n10117 Berlin" }
    its('country_code.downcase') { should == 'de' }

    describe "after #convert_to_format_with_separate_fields" do
      before { @profile_field.convert_to_format_with_separate_fields }

      its(:street_with_number) { should == 'Postfach 1234' }
      its(:postal_code) { should == '10117' }
      its(:city) { should == 'Berlin' }
      its(:value) { should == "Postfach 1234\n10117 Berlin" }
      its('country_code.downcase') { should == 'de' }
      it { should_not have_flag :needs_review }
    end
  end

  describe "when separate fields are stored already" do
    before do
      @profile_field.first_address_line = 'Pariser Platz 1'
      @profile_field.postal_code = '10117'
      @profile_field.city = 'Berlin'
      @profile_field.save
    end

    its(:street_with_number) { should == 'Pariser Platz 1' }
    its(:postal_code) { should == '10117' }
    its(:city) { should == 'Berlin' }
    its(:value) { should == "Pariser Platz 1\n10117 Berlin" }
    its('country_code.downcase') { should == 'de' }

    describe "after #convert_to_format_with_separate_fields" do
      before { @profile_field.convert_to_format_with_separate_fields }

      its(:street_with_number) { should == 'Pariser Platz 1' }
      its(:postal_code) { should == '10117' }
      its(:city) { should == 'Berlin' }
      its(:value) { should == "Pariser Platz 1\n10117 Berlin" }
      its('country_code.downcase') { should == 'de' }
      it { should_not have_flag :needs_review }
    end
  end

  describe "for a french address that can be geocoded" do
    before { @profile_field.update_attributes value: "44 Rue de Stalingrad, Grenoble, Frankreich" }

    its(:street_with_number) { should include '44' }
    its(:street_with_number) { should include 'Rue de Stalingrad' }
    its(:postal_code) { should == '38100' }
    its(:city) { should == 'Grenoble' }
    its(:value) { should == "44 Rue de Stalingrad, Grenoble, Frankreich" }
    its('country_code.downcase') { should == 'fr' }

    describe "after #convert_to_format_with_separate_fields" do
      before { @profile_field.convert_to_format_with_separate_fields }

      its(:street_with_number) { should == '44 Rue de Stalingrad' }
      its(:postal_code) { should == '38100' }
      its(:city) { should == 'Grenoble' }
      its(:value) { should == "44 Rue de Stalingrad\n38100 Grenoble\nFrance" }
      its('country_code.downcase') { should == 'fr' }
      it { should have_flag :needs_review } # since "Frankreich" has been replaced by "France".
    end
  end

  describe "for a french address with separate fields" do
    before do
      @profile_field.first_address_line = '44 Rue de Stalingrad'
      @profile_field.postal_code = '38100'
      @profile_field.city = 'Grenoble'
      @profile_field.country_code = :fr
      @profile_field.save
    end

    its(:street_with_number) { should == '44 Rue de Stalingrad' }
    its(:postal_code) { should == '38100' }
    its(:city) { should == 'Grenoble' }
    its(:value) { should == "44 Rue de Stalingrad\n38100 Grenoble\nFrance" }
    its('country_code.downcase') { should == 'fr' }

    describe "after #convert_to_format_with_separate_fields" do
      before { @profile_field.convert_to_format_with_separate_fields }

      its(:street_with_number) { should == '44 Rue de Stalingrad' }
      its(:postal_code) { should == '38100' }
      its(:city) { should == 'Grenoble' }
      its(:value) { should == "44 Rue de Stalingrad\n38100 Grenoble\nFrance" }
      its('country_code.downcase') { should == 'fr' }
      it { should_not have_flag :needs_review }
    end
  end

  describe "for a british address" do
    before do
      @profile_field.first_address_line = "King's College"
      @profile_field.second_address_line = "King's Parade"
      @profile_field.postal_code = "CB2 1ST"
      @profile_field.city = "Cambridge"
      @profile_field.country_code = 'GB'
      @profile_field.save
    end

    # https://en.wikipedia.org/wiki/Address_(geography):
    #
    # > there are differences in the placement of postal codes: in the UK, they are written on a
    # > separate line at the end of the address; in Australia, Canada and the United States, they
    # > usually appear immediately after the state or province, on the same line; in Austria,
    # > Belgium, France, Germany and The Netherlands they appear before the city, on the same line.
    #
    its(:value) { should == "King's College\nKing's Parade\nCambridge\nCB2 1ST\nUnited Kingdom"}
  end

  describe "#country_code" do
    subject { @profile_field.save; @profile_field.reload.country_code }
    describe "when set as symbol" do
      before { @profile_field.country_code = :at }
      it { should == 'at' }
    end
    describe "when set in small letters" do
      before { @profile_field.country_code = 'at' }
      it { should == 'at' }
    end
    describe "when set in capital letters" do
      before { @profile_field.country_code = 'AT' }
      it { should == 'at' }
    end
  end
end