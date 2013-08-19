require 'spec_helper'

describe ProfileSection do
  describe "#profile_field_types" do
    subject { @profile_section.profile_field_types }
    describe "for section :general" do
      before do
        @user = create(:user)
        @profile_section = @user.profile.section_by_title(:general)
      end
      it { should include "ProfileFieldTypes::Klammerung" }
    end
  end
end
