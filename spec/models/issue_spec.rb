require 'spec_helper'

describe Issue do
  
  describe ".unresolved" do
    before do
      @resolved_issue = Issue.create(resolved_at: Time.zone.now)
      @unresolved_issue = Issue.create()
    end
    subject { Issue.unresolved }
    it { should include @unresolved_issue }
    it { should_not include @resolved_issue }
  end
  
  describe ".scan" do
    describe "()" do
      subject { Issue.scan }
      describe "when a bad address is present" do
        before { @address_field = ProfileFieldTypes::Address.create(label: "Home Address", value: "Unknown") }
        its(:count) { should == 1 }
        its('first.title') { should == 'issues.address_has_too_few_lines' }
        its('first.reference') { should == @address_field }
      end
    end
    
    describe "(address_field)" do
      subject { Issue.scan(@address_field) }
      describe "for a good address field" do
        before { @address_field = ProfileFieldTypes::Address.create(label: "Home Address", value: "Pariser Platz 1\n 10117 Berlin") }
        it { should == [] }
      end
      describe "for a potential address with too few lines" do
        before { @address_field = ProfileFieldTypes::Address.create(label: "Home Address", value: "Unknown") }
        its(:count) { should == 1 }
        its('first.title') { should == 'issues.address_has_too_few_lines' }
        its('first.reference') { should == @address_field }
      end
      describe "for a potential address with too many lines" do
        before { @address_field = ProfileFieldTypes::Address.create(label: "Home Address", value: "c./o. Jean-Luc Picard\n44 Rue de Stalingrad\nGrenoble\nFrankreich\n(Adresse ist im Auslands-BV)") }
        its(:count) { should == 1 }
        its('first.title') { should == 'issues.address_has_too_many_lines' }
        its('first.reference') { should == @address_field }
      end
    end

    describe "(address_fields)" do
      subject { Issue.scan(ProfileFieldTypes::Address.all) }
      before do
        @good_address_field = ProfileFieldTypes::Address.create(label: "Home Address", value: "Pariser Platz 1\n 10117 Berlin")
        @bad_address_field = ProfileFieldTypes::Address.create(label: "Home Address", value: "Unknown")
      end
      its(:count) { should == 1 }
      its('first.reference') { should == @bad_address_field }
    end
  end

end
