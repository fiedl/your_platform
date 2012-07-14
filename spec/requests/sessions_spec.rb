require 'spec_helper'

describe "Sessions" do
  describe "New Session Page", js: true do
    
    before do
      visit new_session_path
    end

    subject { page }

    describe "Form elements" do
      it { should have_field( 'login_name' ) }
      it { should have_field( 'password' ) }
    end


  end
end
